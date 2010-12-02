# Page Factory

An experimental Radiant extension for defining content types/page templates. The intent is to stay light and reuse instead of rebuild.

There are three basic questions when dealing with content types in any CMS:

+ Content Definition: what parts make up a particular kind of page?
+ Templating: what's the markup for each type of page/set of parts?
+ Versioning: how do we track and share changes to definitions & templates?

Page Factory is meant to address the first point, defining pages. Templating and versioning can be achieved with existing extensions and don't need to be reinvented. I like the combination of Nested Layouts and File System Resources, but the goal is to create an extension that's agnostic on those matters.

## Compatibility

**PageFactory 1.0.1** (available as a gem) works with Radiant 0.9.0 and 0.9.1.

**PageFactory 1.1.0** works on Radiant edge, and uses the original PageFactory::Base class.

**PageFactory 2.0** also works on Radiant edge, but does away with the PageFactory::Base class. All methods are defined directly on the Page class itself. PageFactory 2.0 also includes support for managing Page Fields.

## Goals

I'm using the word "Factory" very deliberately. A traditional content type model is attached to a page and to some extent dictates what you can and cannot do with that page.

This is a different approach. I want a _factory_ that only cares about setting up new pages, and doesn't make any page modifications until I tell it to. I want to retain all of the flexibility that comes with Radiant.

I want my factories to set up pages for me and then stay out of my way. Using factories shouldn't prevent me from creating a Plain Old Page with my own choice of parts; nor should they prevent me from modifying pages after they're created.

Page factories shouldn't fundamentally alter the way Pages work. I don't want to overload the `body` part for use as a layout container. Nor do I want to use a web interface to manipulate content types. A Page factory should be a regular Ruby class; I should be able to inherit or extend it.

## Usage

PageFactory is meant to provide a way of defining content types without altering the page editing experience, or the way pages fundamentally behave. A content type is just a default set of parts and fields, defined within Page or one of its subclasses.

Let's say I'm creating a Radiant site for my company, and I need to create an employee directory. I'll have a lot of pages that represent individual employees, and each page will need the same basic parts: first name, last name, and biography.

Rather than manually adding these parts to every employee page, it would be nice if I could simply get a new page with these parts already added. Page Factory lets me declare the default parts in one place.

Later I can make changes to existing Page classes and ask PageFactory to sync those changes to any existing content.

### Defining Page Parts

The first thing I'll do (after installing PageFactory) is to create a class for "Employee" pages. I'll create `employee_page.rb` and put it somewhere convenient:

 * Inside an extension, in `app/models`
 * In my local project root, in `app/models`
 * In my local project root, in `lib`

Note that the `_page.rb` suffix is required.

Next I need to create the EmployeePage class and declare the parts I need:

    class EmployeePage < Page
      part 'first name'
      part 'last name'
      part 'biography'
    end

I visit /admin/pages, and click "Add Child." Hey, there's a popup listing all of the available page types! I select "Employee" and I'm taken to a new page. The first name, last name, and biography parts are waiting for me -- neat!

But I don't need the default "extended" part on my employees page. Let's get rid of it:

    class EmployeePage < Page
      part 'first name'
      part 'last name'
      part 'biography'
      remove_part 'extended'
    end

Repeat the steps to add a new page, and the "extended" part is no longer taking up space.

I can manage Page Fields just as easily with the `field` and `remove_field` methods.

### Additional part options

I'll be adding a page for each of my coworkers, but I want them to log in and fill out their own biographies. In the meantime, I want some placeholder text in the biography part, even if it's just dummy text. That should motivate everyone to actually fill it out.

I'll edit my page class to add the dummy text:

    class EmployeePage < Page
      part 'first name'
      part 'last name'
      part 'biography', :content => "Lorem ipsum dolor sit amet."
    end

Now when I add a new Employee page, the biography field will be pre-populated with this dummy text. But I want to make it clear that people should replace this with actual content. (Not all of my coworkers speak Latin.) I can add a little helper text that will be shown on the "biography" part tab, in order to explain what this part is used for:

    class EmployeePage < Page
      part 'first name'
      part 'last name'
      part 'biography', :content => "Lorem ipsum dolor sit amet.",
                        :description => "Please replace this with one or two paragraphs about yourself."
    end

The helper text gets displayed right above the text field on the biography tab for all new Employee pages.

### Updating existing content

#### Adding parts

I spent all day adding employee pages for each of my coworkers... and then my boss tells me that the employee pages should list people's department. I can add a 'department' part to my EmployeePage, but this won't affect any employee pages I've already created.

Luckily, I won't have to go back through each existing employee page to manually add a department part. I can run the following rake task:

    $ rake radiant:extensions:page_factory:refresh:soft

This iterates over every page and adds any parts that are declared in that page's class, but missing from the instance. Now all of my existing Employee pages have been updated with an empty "department" part.

It's called a "soft" refresh because it adds parts, but it won't change or remove any content. If I've made changes to other classes but I want to restrict this rake task to just the Employee pages, I can pass in a single class name as an argument:

    $ rake radiant:extensions:page_factory:refresh:soft[EmployeePage]

I can pass Page or any subclass. If no class is given, the task is run on every page in my database.

#### Removing parts

The boss just changed her mind about displaying everyone's department. This always happens! No problem though, I can just as easily remove the extra part. I just remove it from my class definition and run this task:

    $ rake radiant:extensions:page_factory:refresh:hard[EmployeePage]

Unlike a soft refresh, a hard refresh _will_ alter or remove content. In this case, it goes through all of my Employee pages and removes any parts that are no longer declared in the class.

### Other factory options

#### Descriptions

If you have a lot of factories, it might be helpful to add a description to each so that you remember what they're all used for.

    class EmployeePage < Page
      description "An employee profile page."

      part 'first name'
      part 'last name'
      ...
    end

The description appears as a tool tip in the Add Child dropdown.

#### Default layouts

Our very talented designer has just sent me the markup for the employee page. I'd like to put this in a layout and assign it to all the employee pages -- that way I only have to edit it in one place if there are changes later. I create a new layout called "Employee" and paste in the markup. I can make this the default layout for Employee pages by passing its name to the factory:

    class EmployeePage < Page
      layout "Employee"
      
      part 'first name'
      part 'last name'
      part 'biography', :content => "Lorem ipsum dolor sit amet.",
                        :description => "..."
    end

Now the Employee layout will be automatically selected whenever I create a new Employee page. If I want to update all of my previously created Employee pages to use this new layout, I can do this by running the hard refresh task.

### Working with pages

Good news! Because PageFactory made it so easy to create and maintain our site, I was awarded the Lifetime Employee Achievement Award! As part of this, I get to have a photo on my employee page. I'll use this nice one of me in a dapper hat.

This will require an extra page part, to hold the URL for my photo. It will also require a slightly different layout, to hold the image tag.

Does this mean I need to create a new page class to account for one single page? Nope! PageFactory was built with flexibility in mind, and doesn't prevent you from working with pages in the ways that you're used to.

I can just edit my own page in the page tree and add a new 'photo url' part, then change the layout to one that accommodates a photo. The EmployeePage class doesn't care what happens to instances after they've been created. And if anyone ever finds out I've been filching copy paper and revokes my award, I can just as easily remove that extra part and change the layout back to the default Employee layout.

(I do have to be careful about running the hard refresh task, however. That will remove my photo part, because it isn't defined in the class. It would also reset my layout to the default Employee layout. I can safely run it as long as I specify a different class name.)

If I leave the plain old Page class alone, I can add basic pages whenever I want -- I don't have to rely on PageFactory methods for everything. This makes it easy to add new pages without thinking about about parts and fields ahead of time.