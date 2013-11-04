# Why do I create this project?

For the job of Linux C/C++ programming, I have used vim for about 3 years and like this editor very much. At first, I just follows others' guide and download a lot of plugins in the runtime path with little configuration and costumization. Half a years ago, I re-organized the plugins and manage using git. Unfortunately, I didn't use any plugin to manage the plugins(such as vundle, pathogen etc.). I put all the plugins in the same directory and manage it all by myself. It's a huge task and hard to update because I did some costumizations. Also I added some plugins myself to load plugins, compile/run program, automaticly generate the tags and so on. I want to manage the plugins but it's very difficult. So I create this project and want to build the vim plugin FW for easy managing, scaling and intalling.

# What's the first plugin?

The first plugin should cover the basic features:

* Log Interface for debugging
* Exception handler
* Map managing for key maps
* command managing for command control
* View template, need a view to configure
* configuration, for all the configure parameters
* Plugin managing, for plugin information and status
* common tools library

# How to manage plugins ?

My idea is to organize the plugins using directory structure. Install the base plugin as describe at first, and then install plugin suite. For the purpose of easy managing, scaling and installing, the plugin should cover the following features:

* Search the plugin
* Download the plugin
* Load the plugin dynamic
* handle the dependancies

