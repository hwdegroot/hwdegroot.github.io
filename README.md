Getting started
==

This is the repository for my blog, hosted on [rikdegroot.io](https://rikdegroot.io)

Clone the repo
---

    git clone git@github.com:hwdegroot/rikdegroot.io.git --recursive

or

    git clone git@github.com:hwdegroot/rikdegroot.io.git
    git submodule update --init


Troubleshooting
---

Q: I am getting a getting `<resources.ExecuteAsTemplate>: error calling ExecuteAsTemplate: type <nil> not supported in Resource transformations` when running `make serve`

A: Did you run `git submodule update --init`?

Run locally
---

    make serve

This will require you to have [`docker`](https://www.docker.com) and [`GNU Make`](https://www.gnu.org/software/make/)

Check out the [`Makefile`](https://github.com/hwdegroot/rikdegroot.io/blob/main/Makefile) for all available commands.

Then fire up a browser and navigate to [http://localhost:8888](http://localhost:8888)

Create new post
---

    make post NAME=<name>


Contributiong
==

see [contribution guide](CONTRIBUTING.md)


