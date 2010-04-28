# Using PageFactory

PageFactory is meant to provide a way of defining content types without altering the page editing experience, or the way pages fundamentally behave. A content type is just a set of parts that you can re-use to create many pages with the same structure.

Let's say I'm creating a Radiant site for my company, and I need to create an employee directory. I'll have a lot of pages that represent individual employees, and each page will need the same basic parts: first name, last name, and biography.

Rather than add these parts to every employee page, it would be nice if I could simply get a new page with these parts already added. Page Factory lets me define "factories" which will set up my new pages exactly the way I want. I can have multiple factories, and I can make changes to existing factories and ask them to update my existing content.

## Creating new factories

The first thing I'll do (after installing PageFactory and running `rake db:migrate:extensions`) is to create a factory for "Employee" pages. I'll create a file called "employee_page_factory.rb" (the `_page_factory` suffix is mandatory.) I can put this in the app/models/ or lib/ directory of any extension, or a lib/ directory at the root of my Radiant project.

I need to tell my factory what parts I want:

    class EmployeePageFactory < PageFactory::Base
      part 'first name'
      part 'last name'
      part 'biography'
    end

I visit /admin/pages, and click "Add Child." Hey, there's a popup here asking me what kind of page to add! I select "Employee Page" and I'm taken to a new page. The first name, last name, and biography parts are waiting for me! Neat!

But I don't need the default "extended" part on my employees page. Let's get rid of it:

    class EmployeePageFactory < PageFactory::Base
      part 'first name'
      part 'last name'
      part 'biography'
      remove 'extended'
    end

Repeat the steps to add a new page, and the "extended" part is no longer taking up space.

## Additional part options

I'll be adding a page for each of my coworkers, but I want them to log in and fill out their own biographies. In the meantime, I want some placeholder text in the biography part, even if it's just dummy text. That should motivate everyone to actually fill it out.

I'll edit my page factory to add the dummy text:

    class EmployeePageFactory < PageFactory::Base
      part 'first name'
      part 'last name'
      part 'biography', :content => "Lorem ipsum dolor sit amet."
    end

Now when I add a new Employee page, the biography field will be pre-populated with this dummy text. But I want to make it clear that people should replace this with actual content. (Not all of my coworkers speak Latin.) I can add a little helper text that will be shown on the "biography" part tab, in order to explain what this part is used for:

    class EmployeePageFactory < PageFactory::Base
      part 'first name'
      part 'last name'
      part 'biography', :content => "Lorem ipsum dolor sit amet.",
                        :description => "Please replace this with one or two paragraphs about yourself."
    end

The helper text gets displayed right above the text field on the biography tab for all new Employee pages.

## Updating existing content

### Adding parts

I spent all day adding employee pages for each of my coworkers... and then my boss tells me that the employee pages should list people's department. I add a 'department' part to my EmployeePageFactory, but this won't affect any employee pages I've already created.

Luckily, I won't have to go back through each existing employee page to manually add a department part. I can run the following rake task:

    $ rake radiant:extensions:page_factory:refresh:soft

This iterates over every page created with a factory and adds any parts that are listed in the page's factory but missing from the page. Now all of my existing Employee pages have been updated with an empty "department" part.

It's called a "soft" refresh because it adds parts, but it won't change or remove any content. If I had more than one factory and I only wanted to act on Employee pages, I could specify a particular factory:

    $ rake radiant:extensions:page_factory:refresh:soft[employee]

That argument is the name of my factory class minus "page_factory," because this rake task is already long enough.

### Removing parts

The boss just changed her mind about displaying everyone's department. This always happens! No problem though, I can just as easily remove the extra part. I just remove it from my factory definition and run this task:

    $ rake radiant:extensions:page_factory:refresh:hard[employee]

Unlike a soft refresh, a hard refresh _will_ alter or remove content. In this case, it goes through all of my Employee pages and removes any parts that aren't listed in the factory definition.

## Other factory options

### Descriptions

If you have a lot of factories, it might be helpful to add a description to each so that you remember what they're all used for.

    class EmployeePageFactory < PageFactory::Base
      description "An employee profile page."

      part 'first name'
      part 'last name'
      ...
    end

This description appears in the factory selection popup.

### Default layouts

Our very talented designer has just sent me the markup for the employee page. I'd like to put this in a layout and assign it to all the employee pages -- that way I only have to edit it in one place if there are changes later. I create a new layout called "Employee" and paste in the markup. I can make this the default layout by passing its name to the factory:

    class EmployeePageFactory < PageFactory::Base
      layout "Employee"
      
      part 'first name'
      part 'last name'
      part 'biography', :content => "Lorem ipsum dolor sit amet.",
                        :description => "..."
    end

Now the Employee layout will be automatically selected whenever I create a new Employee page. If I want to update all of my previously created Employee pages to use this new layout, I can do this by running the hard refresh task.

### Default page classes

Sometimes it might be useful to set a default page class, if for instance I have a page factory that deals with Archive pages. That's just as easy:

    class ArchivePageFactory < PageFactory::Base
      page_class "ArchivePage"
    end

Again, I'd have to run the hard refresh task to update any existing pages.

## Working with pages

Good news! Because PageFactory made it so easy to create and maintain our site, I was awarded the Lifetime Employee Achievement Award! As part of this, I get to have a photo on my employee page. I'll use this nice one of me in a dapper hat.

This will require an extra page part, to hold the URL for my photo. It will also require a slightly different layout, to hold the image tag.

Does this mean I need to create a new factory and recreate my own employee page? Nope! PageFactory was built with flexibility in mind, and doesn't prevent you from working with pages in the ways that you're used to.

I can just open up my page and add a new 'photo url' part, then change the layout to one that accommodates a photo. The EmployeePageFactory doesn't care what happens to employee pages after they've been created. And if they ever find out I've been filching copy paper and revoke my award, I can just as easily remove that extra part and change the layout back to a normal employee layout.

(I do have to be careful about running the hard refresh task, however. That will remove my photo part, because it isn't defined in the factory, and reset my layout to the default employee layout. I can safely run it as long as I specify another factory name.)

I can also add a plain old page with no factory and add/delete parts as usual -- I don't have to rely on a factory for everything. This makes it easy to add individual pages whenever I want.