---
title: "640 kiloBytes of RAM??! and Why I Bought an IBM 5160"
date: 2020-05-19T18:43:42Z
type: post
tags:
    - development
    - vintage-computing
    - ibm-5160
    - lang-en
images:
    - images/og/ibm-5160.png
disqus_identifier: "f355ef2ad8ff0047813f58db28ac801d"
disqus_title: "640 Kilobytes of RAM??! and Why I Bought an IBM 5160"
showComments: true
---

> 640 Kilobytes!!!!1!!1 I shit you not. That is like 10 times the brainsize of Donald Trump.

Recently I was trying to get my son enthousiastic for programming. He is currently 7 years old and getting interested in all kinds of electronics,
so I thought that getting acquainted with programming would not hurt him. And I like to think of myself as a parent that stimulates his kids, so I used that
as an excuse to look into older computers, because _nostalgics_.

My kids grew up with LED monitors and TV's and never really saw a real cathode tube, except on the episodes of [Pat & Mat](https://en.wikipedia.org/wiki/Pat_%26_Mat).
I still remember the soft fading sound of of the tv turning off and the graphics vanishing into this thin line.

Besides that, I am a fan of clicky keyboards. I have a [DasKeyboard 4C ultimate](https://www.daskeyboard.com/daskeyboard-4C-ultimate/) tenkeyless with Cherry Blue switches and a [4C Profressional](https://www.daskeyboard.com/daskeyboard-4C-tenkeyless-professional/) with brown switches. Sitting at home during the
corona period, made me google old skool stuff a lot.

So first I laid my eyes on a [IBM Model M2](https://clickykeyboards.com/product/ibm-model-m2-1395300-made-by-ibm-06-30-1993/) and got this pretty cheap on
the dutch eBay. Getting this to work on my modern laptop was not rocket science, but not straight forward either. I warned my collegues
that the quiet days at the office were over. But this also opened up a window into vintage computers and computing. What if I could get a vintage computer, I thought. How awesome would that be?

How cool would it be to program a vintage computer with my collegues, or my kids. With all the speed we get nowadays, who still thinks about the limits of computing power. This will be totally different if you have just a fraction of the memory and chip available.

## IBM 5160

I am from 1983. So I was looking for a computer from that year. IBM was _the company_ in those days for personal computing and when it came to makeing PC's (I am NOT an apple fan). So I found that IBM produced the [**IBM PC XT**](https://en.wikipedia.org/wiki/IBM_Personal_Computer_XT) in that year. I also found out that you could still get them online for a reasonable price.
Luckliy I was able to lay my hands on one, in a pretty good state. It came with an [IBM Model M](https://clickykeyboards.com/product-category/1986-1989-ibm-model-m-silver-label/) keyboard with the silver label (the PC is from 1986). The sound of that is even better than than the `Model M2`.

{{< audio "audio/IBM-model-m-oh-that-clicky-sound.mp3" >}}
Need I say more...
{{< /audio >}}

After introducing my kids to th `DIR` command (it was the only one I was pretty sure about it would work), they wanted to type "words" on the old computer (first success).

## Exiting Vim is hard?

So, I know the `DIR` command. But now what. Let's see what commands are available.

* No tab completion. `TAB` just places the cursor somewhere down the line
* No `HISTORY`. You can repeat the last command by pressing the right-arrow.

For a starters, on `IBM DOS` (version 5.0) there is no `$PATH`. The executables are located in `C:\DOS` (or `c:\dos`, because `DOS` don't care about casing). the most executables are located. After a day or two I figured this out, so I finally managed to open my first `BASIC` program. All fine, until I wanted to quit the program. It's not that easy as [exiting `Vim`](https://stackoverflow.com/questions/11828270/how-do-i-exit-the-vim-editor). It took me quite some time googling, until I finally found this [lifesaver](https://stackoverflow.com/questions/44253055/how-can-i-exit-microsoft-gw-basic-ibm-basica-or-other-similar-old-dialects-of).

{{< image "images/basic-startup-screen.jpg" Fit "600x600" >}}
Entering BASIC is peanuts
{{< /image >}}

{{< image "images/cannot-exit-basic.jpg" Fit "600x600" >}}
Stuck in BASIC
{{< /image >}}

{{< video "videos/trying-stuff-in-qbasic.mp4" "letter" >}}
Trying to exit QBASIC. Epic fail
{{< /video >}}

So, now I can start a few commands, but getting all available commands is not that straight forward. There is a lot in the `DOS` directory, but there is no scrolling, and the monitor only is 24 lines.

So figuring out the available commands is using a lot of `DIR *.EXE`'s and `DIR *.COM`'s.

First class fun.

## Show me the pics

Not so long ago I was explaining my collegue (who is using a screensaver), [where a screensaver got its name from](https://en.wikipedia.org/wiki/Screensaver). Back in the days, when we were all running the [pipes](https://www.youtube.com/watch?v=Uzx9ArZ7MUU) so the screen would not f*** up.

But now, sit back and relax...

{{< video "videos/insane-refresh-rate-oldskool-monitor.mp4" >}}
Check this insane refresh rate of the cathode tube. The color of the terminal is magnificent! 😍
{{< /video >}}

{{< video "videos/more-refresh-rate.mp4" "landscape" >}}
And more refresh rate. The mesmerizing fading away of the fonts into the background. Beautiful, just beautiful
{{< /video >}}

{{< image "images/ibm-dos-edit-dutch.jpg" Fit "600x600" >}}
un DOS tres. The fluorescent is soooo pretty.
{{< /image >}}

{{< image "images/wpview-printer-driver-bat-file.jpg" Fit "600x600" >}}
WpPreview
{{< /image >}}

## What next?

So far I had to explain to my son what a `file(name)` and a `command` is (when they were typing "words" the IBM kept returning

```cmd
command or filename incorrect
```

So the experience is already educational :)

To be honest, I do not have a clear idea what I am going to do with it next. I will be playing with it for a while like an 8 year old with his trains.
After the [`#stayathome`](https://twitter.com/hashtag/stayathome) is over, hopefully I can take it to the office, so we can start doing real cool things with it.

I will definitely have to up my [`GOTO`](https://www.qb64.org/wiki/GOTO) skills :)

I will start using my Model M2 for work (sorry collegues), for sure. I will have to remap my function key in [`i3`](https://i3wm.org/), because I am currently using the
windows key for this. But the Model M2 does not have one. But I will overcome.

Besides that, I found this great archive with [manuals](ihttps://archive.org/search.php?query=dos%20ibm) and [bootdisks](http://www.retroarchive.org/dos/disks/). Currently I am trying to get a VM up running PC DOS 5.0 (yes, that is possible in [virtualbox](https://www.youtube.com/watch?v=xfjUkJMe_kw))

The downside, my Cherry MX blue switches feel like second class now.


