---
title: UI automation of a Custom Control
date: 2019-08-02T17:45:07Z
tags:
    - development
    - lang-en
    - TreeViewAdv
    - C#
    - .Net
    - TestStack-White
images:
    - images/og/cover.png
---

Recently I found a blog post I never really published (on an ancient blogger account). However I am not very active in `C#.NET` nowadays, so maybe noone is using this anymore.

Anyway this might actually help some people, so here it is, dug up from the past...

ow, btw the source is gone... `¯\_(ツ)_/¯`

## UIAutomation of TreeViewAdv

I am using the open source tool TreeViewAdv form [Aga.Controls](http://sourceforge.net/projects/treeviewadv/).

As a QA'er I tried to automate this control, but unfortunately the control was not exposing any elements inside the tree. It turned out that UIAutomation was not implemented.

This was an enormous drawback for me, because it narrowed down to a lot of tests with mouseclicks at (x,y) coordinates, which made the tests less robust, and even fail at different screen resolutions.

I started Googling for solutions, but I did not find many. As a result I started looking into *how-to's* for custom winforms controls. Finally I came across [this blog post](http://blogs.msdn.com/b/winuiautomation/archive/2011/05/18/a-ui-automation-bar-chart-sample.aspx) which helped me implementing methods to expose the elements in the tree to the UIAutomation framework.

Michael Bernstein wrote a [blog](http://blogs.msdn.com/b/winuiautomation/archive/2010/07/03/custom-ui-automation-providers-in-depth-part-1.aspx) which also goes in depth on this topic. However the sources are not available anymore.

I ended up forking the control, and implementing UIAutomation detection for the treeview. Because I had quite a hard time figuring out how to implement it all, I will try to explain how I did it, and explain all the steps I did to come to the result.

The forked project can be found at ~~[https://github.com/hwdegroot/treeviewadv](https://github.com/hwdegroot/treeviewadv)~~. In the project you will find the TreeViewAdv with UIAutomation [~~see README~~](https://github.com/hwdegroot/treeviewadv/blob/master/README.md) and an extension to [`TestStack.White`](http://docs.teststack.net/) which helps `white` to detect the element as a treeview/treenode element and the exposed patterns (in the example the ExpandCollapsePattern).

This can be extended to any other pattern that is [supported by the UIAutomation framework](https://msdn.microsoft.com/en-us/library/System.Windows.Automation.Provider(v=vs.110).aspx).

I hope this post will help you implementing and understanding UIAtomationPatterns and providers and giving a handson Automation implementation at the same time.

For any questions feel free to ask.

###  Implementing UIAutomation Serverside

#### Step 1. TreeView

#### Step 1.1 Implement a Automation provider for the TreeView

For the implementation of the provider, the hierarchy is as described in the blogpost of [Guy Barker](http://blogs.msdn.com/b/winuiautomation/archive/2011/05/18/a-ui-automation-bar-chart-sample.aspx). This implements the following three base classes:


1. `BaseFragmentProvider`
1. `BaseFragmentRootProvider`
1. `BaseSimpleProvider`

You will find them in: `Aga.Controls.UIAutomation` besides the `Aga.Controls` project. For the result however, this is not mandatory.

In this example the code snippets refer to those classes.


Secondly there are implementation for the `Providers` in the treeview project. These providers will be called by the Automation framework, and will expose the properties and methods needed. The code snippet below shows the relevant implementation of the TreeViewAdv provider.


```csharp
namespace Aga.Controls.Providers
{
    public class TreeViewAdvProvider : BaseFragmentRootProvider, IExpandCollapseProvider
    {
        ...

        /// <summary>
        /// Gets the window handle
        /// </summary>
        /// <returns>handle</returns>
        protected override IntPtr GetWindowHandle()
        {
            return _treeViewAdv.Handle;
        }

        /// <summary>
        /// Gets the name of the Fragmentroot
        /// </summary>
        /// <returns>Name of treeview</returns>

        protected override string GetName()
        {
            return Name;
        }

        /// <summary>
        /// Get the bounding rect by consulting the control.
        /// </summary>
        public override Rect BoundingRectangle
        {
            get
            {
                var screenRect = _treeViewAdv.RectangleToScreen(_treeViewAdv.DisplayRectangle);
                return new Rect(screenRect.Left, screenRect.Top, screenRect.Width, screenRect.Height);
            }
        }

        /// <summary>
        /// Return first child.
        /// </summary>
        /// <returns>First direct child</returns>
        protected override IRawElementProviderFragment GetFirstChild()
        {
            ...
        }

        /// <summary>
        /// Returns last child.
        /// </summary>
        /// <returns>last child node</returns>
        protected override IRawElementProviderFragment GetLastChild()
        {
            ...
        }

        /// <summary>
        /// Return next nodeat the same level of this node.
        /// </summary>
        /// <returns>Nest sibling node</returns>
        public override IRawElementProviderFragment ElementProviderFromPoint(double x, double y)
        {
            if (_treeViewAdv == null)
                return null;

            var clientPoint = _treeViewAdv.PointToClient(new Point((int)x, (int)y));
            var node = _treeViewAdv.GetNodeAt(clientPoint);

            // First check if the clicked point is on a node in the treeview
            if (node != null)
            {
                return new TreeNodeAdvProvider(_treeViewAdv, this, node);
            }

            // if it is not a node, it might be the column header
            var column = _treeViewAdv.GetColumnAt(clientPoint);

            if (column != null)
            {
                return new TreeColumnProvider(_treeViewAdv, this, column);
            }

            return this;
        }

        ...

        /// <summary>
        /// Gets Pattern provider from <paramref name="patternId" />
        /// </summary>
        /// <param name="patternId">PatternId</param>
        /// <returns>self</returns>
        public override object GetPatternProvider(int patternId)
        {
            switch (patternId)
            {
                case UIAConstants.UIA_EXPAND_COLLAPSE_PATTERN_ID:
                    return this;
                default:
                    return base.GetPatternProvider(patternId);
            }
        }
    }
}
```

Important here is the override of

```csharp
    public override object GetPatternProvider(int patternId)
    {
        ...
    }
```

This method will tell the automation framework what Providers are implemented. Later this will help with getting the ExpandCollapsePattern from the `AutomationElement`


When I want to access the `Collapse()` and `Expand()` method through UIAutomation, the automation framework will look for exposed patterns. This method will teel which providers are supported by my custom provider. The switch statement tells which providers are supported. These are identified by integers (`patternId`), which in are in a constant class `UIAConstants`.


##### Step 1.2 Capture the `WndProc` in the custom control

Afterwards The provider is added to the control, via a few lines of codes, which tell UIAutomation to return the provider when the element is selected in the tree.


```csharp
namespace Aga.Controls.Tree
{
    /// <summary>
    /// Extensible advanced <see cref="TreeView"/> implemented in 100% managed C# code.
    /// Features: Model/View architecture. Multiple column per node. Ability to select
    /// multiple tree nodes. Different types of controls for each node column:
    /// <see cref="CheckBox"/>, Icon, Label... Drag and Drop highlighting. Load on
    /// demand of nodes. Incremental search of nodes.
    /// </summary>
    public partial class TreeViewAdv : Control
    {
        ...

        #region UIAutomation detection

        private TreeViewAdvProvider _provider;

        protected override void WndProc(ref Message m)
        {
            // Handle WM_GETOBJECT. Without this, UIA doesn't
            // know the chart has a UIA Provider implementation.
            if (m.Msg == 0x3D /* WM_GETOBJECT */)
            {
                m.Result = NativeMethods.UiaReturnRawElementProvider(
                    m.HWnd,
                    m.WParam,
                    m.LParam,
                    this.Provider
                );
            }
            else
            {
                base.WndProc(ref m);
            }
        }

        public TreeViewAdvProvider Provider
        {
            get
            {
                if (_provider == null)
                {
                    _provider = new TreeViewAdvProvidger(this);
                }

                return _provider;
            }
        }

        #endregion
    }
}
```

Which element is clicked, is defined by

```csharp
public override IRawElementProviderFragment ElementProviderFromPoint(double x, double y)
{

    var clientPoint = _treeViewAdv.PointToClient(new Point((int)x, (int)y));
    var node = _treeViewAdv.GetNodeAt(clientPoint);
    var column = _treeViewAdv.GetColumnAt(clientPoint);

    if (node != null)
    {
        return new TreeNodeAdvProvider(_treeViewAdv, this, node);
    }

    if (column != null)
    {
        return new TreeColumnProvider(_treeViewAdv, this, column.Index);
    }

    return _treeViewAdv == null ? null : new TreeViewAdvProvider(_treeViewAdv);
}
```


in the TreeViewAdvProvider.

So now the TreeView will return a the relevant provider when a MouseClick is recorded in the control.
Next all that needs to be done is repeat the same step for the headers and the nodes, and let the treeview decide which provider should be returned, depending on whether a node or a column is clicked.
If neither is present at the clicked point, it will return the provider of the tree itself.


#### Step 2. TreeNode

The same implementation can be repeated for the TreeNodeAdv. The code snippet below shows this implementation.


```csharp
namespace Aga.Controls.Providers
{
    public class TreeNodeAdvProvider : BaseFragmentProvider, IExpandCollapseProvider
    {
        ...

        /// <summary>
        /// Gets Pattern provider from <paramref name="patternId" />
        /// </summary>
        /// <param name="patternId">PatternId</param>
        /// <returns>self</returns>
        public override object GetPatternProvider(int patternId)
        {
            switch (patternId)
            {
                case UIAConstants.UIA_EXPAND_COLLAPSE_PATTERN_ID:
                    return this;
                default:
                    return base.GetPatternProvider(patternId);
            }
        }

        ...

        /// <summary>
        /// Get the bounding rect by consulting the control.
        /// </summary>
        public override Rect BoundingRectangle
        {
            get
            {
                var screenRect = _treeViewAdv.RectangleToScreen(_treeViewAdv.GetNodeBounds(_node));

                AddStaticProperty(UIAConstants.UIA_IS_OFFSCREEN_PROPERTY_ID, !_node.IsVisible);

                if (!_node.IsVisible)
                    return Rect.Empty;

                var margin = _treeViewAdv.Margin;
                double offsetTop = (double) (
                    _treeViewAdv.ColumnHeaderHeight - (
                        _treeViewAdv._vScrollBar.Value * _treeViewAdv.RowHeight
                        )
                    );
                var offsetLeft = (margin.Left / 2) - _treeViewAdv._hScrollBar.Value;

                return new Rect(
                    screenRect.Left + offsetLeft,
                    screenRect.Top + offsetTop,
                    screenRect.Width,
                    screenRect.Height
                );
            }
        }

        /// <summary>
        /// Return first child.
        /// </summary>
        /// <returns>First direct child</returns>
        protected override IRawElementProviderFragment GetFirstChild()
        {
            ...
        }

        /// <summary>
        /// Returns last child.
        /// </summary>
        /// <returns>last child node</returns>
        protected override IRawElementProviderFragment GetLastChild()
        {
            ...
        }

        /// <summary>
        /// Return next nodeat the same level of this node.
        /// </summary>
        /// <returns>Nest sibling node</returns>
        protected override IRawElementProviderFragment GetNextSibling()
        {
            ...
        }

        /// <summary>
        /// Gets the preceeding node at the same level.
        /// </summary>
        /// <returns>Preceeding node.</returns>
        protected override IRawElementProviderFragment GetPreviousSibling()
        {
            ...
        }

        ...

    }
}
```

This provider exposes another pattern


```csharp
AddStaticProperty(UIAConstants.UIA_IS_OFFSCREEN_PROPERTY_ID, !_node.IsVisible);
```


This property tells the Automation framework if the AutomationElement is offscreen. Offscreen elements are not clickable by the automationframwork (see [MSDN](https://msdn.microsoft.com/en-us/library/system.windows.automation.automationelement.automationelementinformation.isoffscreen(v=vs.100).aspx), which is expected behaviour in this case.)

The snippet below shows how this is used to make invisible nodes inaccesible to the Automation Client

```csharp
public override Rect BoundingRectangle
{
    get
    {
        ...
        AddStaticProperty(UIAConstants.UIA_IS_OFFSCREEN_PROPERTY_ID, !_node.IsVisible);
        ...
    }
}
```

#### Step 3. TreeHeader and columns

This example will distinguish between the TreeHeader and the Column header, but that is not mandatory.


Mainly one would want to be able to identify the tree columns because the can be used for sorting.

The implementation is pretty straight-forward, compared to the previous two providers.

#### Step 4. ExpandCollapseProvider

Next the methods and properties of `IExpandCollapseProvider` have to be implemented to tell the control what to do when called from the AutomationElement.

The snippet below shows the implementation off the `TreeNodeAdvProvider`. For the `TreeViewAdvProvider` this is similar.

```csharp
/// <summary>
/// Exposes Expand from node.
/// </summary>
public void Expand()
{
    if (_node.CanExpand && !_node.IsExpanded)
        _node.Expand();
}

/// <summary>
/// Exposes Collapse from node.
/// </summary>
public void Collapse()
{
    if (_node.CanExpand && _node.IsExpanded)
        _node.Collapse();
}

ExpandCollapseState IExpandCollapseProvider.ExpandCollapseState
{
    get { return ExpandCollapseState; }
}

/// <summary>
/// Custom getter.
/// Gets the state, expanded or collapsed, of the control.
/// </summary>
public ExpandCollapseState ExpandCollapseState
{
    get
    {
        if (_node.IsLeaf)
            return ExpandCollapseState.LeafNode;

        if (_node.IsExpanded)
            return ExpandCollapseState.Expanded;

        if (_node.IsExpandedOnce)
            return ExpandCollapseState.PartiallyExpanded;

        return ExpandCollapseState.Collapsed;
    }
}
```

#### Step 5. Exposing ExpandCollapsePatternProvider

We want the Automation framework to call our custoim implementation when the ExpandCollapsePattern is called. Therefore we need to tell the provider to return our provider instead of the base provider for the exposed methods. This is implemented through the `GetPatternProvider()`. The code snippet below shows that when the AutomationELement is called with the `ExpandCollapsePatternId`, our custom provider is returned, and not the base provider.

```csharp
/// <summary>
/// Gets Pattern provider from <paramref name="patternId" />
/// </summary>
/// <param name="patternId">PatternId</param>
/// <returns>self</returns>
public override object GetPatternProvider(int patternId)
{
    switch (patternId)
    {
        case UIAConstants.UIA_EXPAND_COLLAPSE_PATTERN_ID:
            return this;
        default:
            return base.GetPatternProvider(patternId);
    }
}
```

Note the `UIAConstants.UIA_EXPAND_COLLAPSE_PATTERN_ID` which will do that magic for us.


## Extending White Framework with custom UIItem ClientSide

When taking all the effort to copy-paste this code, it would be nice if it also works. Below is a snippet of an extension method for the [Teststack.White](http://docs.teststack.net/) framework, which will define a `TreeViewItem` and a `TreeNodeItem` that will implement our custom control, and will also call the `Expand()` and `Collapse()` methods.


### Step 6. Extend White with the custom UIItem

First we need an extension to `white`. Since they both have implement the `IExpandCollaseProvider` the inherit from the base class `ExpandCollapseUIItem`.


The snippet below tries to parse the pattern to the `ExpandCollapsePattern`

```csharp
protected ExpandCollapsePattern GetExpandCollapsePattern(AutomationElement targetControl)
{
    ExpandCollapsePattern expandCollapsePattern;

    try
    {
        expandCollapsePattern = targetControl.GetCurrentPattern(ExpandCollapsePattern.Pattern)
            as ExpandCollapsePattern;
    }
    catch (InvalidOperationException)
    {
        return null;
    }

    return expandCollapsePattern;
}
```

Here it becomes clear why we had to tell our provider to return our own control for the `UIAConstants.UIA_EXPAND_COLLAPSE_PATTERN_ID`, because the `AutomationElement.GetCurrentPattern(ExpandCollapsePattern.Pattern)` will be `null` if we did not take that effort.


Next `Expand()` and `Collapse()` can be called as method of the pattern (the snippet shows `Expand()`).

```csharp
/// <summary>
/// Implements Collapse
/// </summary>
public virtual void Expand()
{
    var expandCollapsePattern = GetExpandCollapsePattern(automationElement);

    if (
        expandCollapsePattern == null
        || expandCollapsePattern.Current.ExpandCollapseState == ExpandCollapseState.LeafNode
    )
    {
        return;
    }

    try
    {
        if (
            expandCollapsePattern.Current.ExpandCollapseState == ExpandCollapseState.Collapsed
            || expandCollapsePattern.Current.ExpandCollapseState == ExpandCollapseState.PartiallyExpanded
        )
        {
            expandCollapsePattern.Expand();
        }
    }
    catch (ElementNotEnabledException enee)
    {
        throw;
    }
    catch (InvalidOperationException ioe)
    {
        throw;
    }
}
```


Now the extension for the `white` framework is a piece of cake:


#### TreeNodeItem

```csharp
namespace TestStack.White.UIITems.Custom
{
    [ControlTypeMapping(CustomUIItemType.Custom)]
    public class TreeNodeItem : ExpandCollapseUIItem
    {
        public TreeNodeItem(AutomationElement automationElement, ActionListener actionListener)
            : base(automationElement, actionListener)
        { }

        protected TreeNodeItem() { }
    }
}
```


#### TreeViewItem

```csharp
namespace TestStack.White.UIITems.Custom
{
    [ControlTypeMapping(CustomUIItemType.Custom)]
    public class TreeViewItem : ExpandCollapseUIItem
    {
        public TreeViewItem(AutomationElement automationElement, ActionListener actionListener)
            : base(automationElement, actionListener)
        { }

        protected TreeViewItem() { }

        public override void Expand()
        {
            var expandCollapsePattern = GetExpandCollapsePattern(automationElement);

            if (
                expandCollapsePattern == null
                || expandCollapsePattern.Current.ExpandCollapseState == ExpandCollapseState.LeafNode
            ) {
                return;
            }

            try
            {
                expandCollapsePattern.Expand();
            }
            catch (ElementNotEnabledException enee)
            {
                throw;
            }
            catch (InvalidOperationException)
            {
                throw;
            }
        }

        public override void Collapse()
        {
            var expandCollapsePattern = GetExpandCollapsePattern(automationElement);

            if (
                expandCollapsePattern == null
                || expandCollapsePattern.Current.ExpandCollapseState == ExpandCollapseState.LeafNode
            ) {
                return;
            }

            try
            {
                expandCollapsePattern.Collapse();
            }
            catch (ElementNotEnabledException enee)
            {
                throw;
            }
            catch (InvalidOperationException)
            {
                throw;
            }
        }
    }
}
```

### Using TestStack.White to test the TreeView

Test TreeView and the Expand and Collapse Behaviour.

After Test initialization this yields to te following test

```csharp
[TestMethod]
public void select_treeview()
{
    using (
        CoreAppXmlConfiguration.Instance.ApplyTemporarySetting(c => {
            c.FindWindowTimeout = 1000; c.BusyTimeout = 1500;
        })
    ) {
        var searchCriteria = SearchCriteria.ByAutomationId("MainForm");
        var mainForm = _application.GetWindow(searchCriteria, InitializeOption.NoCache);

        mainForm.Focus();
        var tree = mainForm.Get<TreeViewItem>(SearchCriteria.ByAutomationId("treeViewAdv1"));
        tree.Expand();

        var node1 = tree.Get<TreeNodeItem>(SearchCriteria.ByAutomationId("Root1"));
        var node14 = node1.Get<TreeNodeItem>(SearchCriteria.ByAutomationId("Root1.Child4"));
        var node143 = node14.Get<TreeNodeItem>(SearchCriteria.ByAutomationId("Root1.Child4.Child43"));

        Assert.IsTrue(node143.Visible);
        Assert.IsTrue(node14.Visible);

        node14.Collapse();
        node143 = node14.Get<TreeNodeItem>(SearchCriteria.ByAutomationId("Root1.Child4.Child43"));

        Assert.IsFalse(node143.Visible);

        tree.Collapse();
        Assert.IsFalse(node14.Visible);
    }
}
```


Here you can see that the custom control can be used to get a TreeNodeItem and a TreeViewItem. ChildNodes are visible when the parent is Expanded, but not when the parent is collapsed. The visibility is exposed through the `IsOffScreenProperty`. This is achieved by toggling the `UIAConstants.UIA_IS_OFFSCREEN_PROPERTY_ID` in the provider, based on the node's visibility.

Hope this helps anyone with a full-circle implementation.
