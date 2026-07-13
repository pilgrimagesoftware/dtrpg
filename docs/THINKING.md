# Thinking Out Loud

I wanted to record here my thoughts on this project, how it started, the motivation
for working on it, and how I'm approaching it (both before and now).

## Motivation

I have a lot of RPG books on DriveThruRPG. I like to keep them stored locally and up-to-date.
OneBookShelf, the company behind DriveThruRPG, provides an application that allows you to sync 
your books with your local machine, but it's (and no disrespect meant here) a lowest common 
denominator app (possibly Electron?), and the UI/UX is not great. 

I've been trying to learn Rust, and looking for a project to sink my teeth into, and I like
desktop applications.

It turns out that DriveThruRPG provides an API that their desktop app uses, so I looked into
reverse engineering it and building an application to use it.

## Approach

In the beginning, I was just trying to get a sense of what the API was like and how it worked.
Using a combination of Proxyman and Postman, I was able to start poking at the API to get an
understanding of it.

I was also looking at GUI frameworks for Rust, such as Tauri. But then I stumbled on Zed, and
discovered its Rust-based GUI framework: GPUI. I was excited to try it out and see how it works.

A lot of it was slow-going. But then, as part of my job, I was learning more about LLMs and 
leveraging Claude and ChatGPT to write small scripts and utilities.

These three elements (Rust, GPUI, and LLMs) came together, and have allowed me to make quite a
bit of progress on the project of late. 

Then I added OpenSpec to the mix. As I test out the application, I'm using it to generate OpenAPI 
specs for the design and implementation.

That's where we are now.

## Other Notes

In an attempt to keep things organized, I've been using a hierarchy of repositories to keep 
things separated and structured, using Git submodules to establish that structure.
I've attempted to organize the codebase into logical modules and packages, according to 
purpose and language, and to keep the robot's files up-to-date with information on where to 
put things.
