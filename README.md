# Page Factory

An experimental Radiant extension for defining content types/page templates. The intent is to stay light and reuse instead of rebuild.

There are three basic questions when dealing with content types in any CMS:

+ Content Definition: what parts make up a particular kind of page?
+ Templating: what's the markup for each set of parts?
+ Versioning: how do we track and share changes to definitions & templates?

Page Factory is meant to address the first point, defining pages. Templating and versioning can be achieved with existing extensions and don't need to be reinvented. I like the combination of Nested Layouts and File System Resources, but the goal is to create an extension that's agnostic on those matters.

## Installation

Radiant 0.9.0/0.9.1: use PageFactory 1.0.1 (gem version preferred.)

Radiant > 0.9.1: use PageFactory 1.1.1 (vendored) and deactivate the core
PageMenu extension in config/environment.rb:

    config.extensions -= [:page_menu]

## Goals

I'm using the word "Factory" very deliberately. A traditional "content type" is a model that's attached to a page for the page's entire lifespan. To some extent, the content type dictates what you can and cannot do with that page.

This is a different approach. I want a _factory_ that only cares about setting up new pages, and doesn't make any page modifications until I tell it to. I want to retain all of the flexibility that comes with Radiant.

I want the following behaviors in my solution:

### Flexibility

I want my factories to set up pages for me and then stay out of my way. Using factories shouldn't prevent me from creating a Plain Old Page with my own choice of parts; nor should they prevent me from modifying pages after they're created.

### Simplicity

Page factories shouldn't fundamentally alter the way Pages work. I don't want to overload the `:body` part for use as a layout container. Nor do I want to use a web interface to manipulate content types. A Page factory should be a regular Ruby class; I should be able to inherit or extend it.

### Modularity

I want my factories to respect the division between presentation and behavior. Factories can _suggest_ a Page class, but shouldn't prevent you from changing that class on new or existing records. I'd like to take a similar approach to layouts -- flexibility is a requirement, not an enhancement.

## Some use cases

In addition to the core task of defining content types, there are some specific cases I want Page Factory to address:

### Generic pages

I want to add a one-off page somewhere. In the past, generic pages have been catch-all content types with enough parts to fit any use case. They're ugly and hard to use.

I should be able to add a Plain Old Page without setting up a content type first. I should be able to add only those parts I need. I should be able to use the `:body` part to hold that page's unique markup, just like normal Radiant usage.

### Edge cases

There's a page that needs to look or behave just a little differently from others of its kind. Instead of making its content type pull double duty, or creating a content type to handle a single page, I should be able to switch this page to a different layout. Or use a different page class. Or add a single page part to it.

Page factories shouldn't have an opinion about any of those attributes until you tell it to take action on a page or set of pages.

## Usage

See EXAMPLES.md for a detailed walkthrough.

## Notes on implementation

+   **Syncing.** Because I'm not exposing these factories in the admin UI, there's no need to do this in real-time. Unless explicitly asked, the methods responsible for altering existing content ignore Plain Old Pages so that you have at least one type of Page that's always open to modification and not in any danger of being overwritten.

+   **Changing factories.** I decided not to implement a way to change a page's factory after creation. This is mostly because I felt adding a new element to the page edit interface wasn't in line with PageFactory's stated goal of changing as little as possible about page behavior. It was confusing to have both a 'Page Type' select and a factory/template/whatever select side-by-side.

    Additionally, I haven't worked out how changing a page's factory should work. Do the parts get reassigned on the fly? What happens if the pages share some parts?