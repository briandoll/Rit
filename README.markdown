rit.
====

> Ritardando — immediate slowing down (abbreviation: rit. or more specifically, ritard.)

rit. is a standalone web application that allows users to edit and schedule content.  Content is served up to a consuming application as a web service.


Design Goals
------------
 * CMSes suck, especially Radiant.  We don't want our application to live inside a CMS.
 * Do one thing and do it well.  rit. schedules content.  That's pretty much it.
 * Don't be clever.  We're not clever so we probably can't make a computer clever.
 * Be fast.  Cache in rit. so that the consuming application doesn't have to.


Terminology
-----------
### Plate
A *Plate* is a class of content.  A plate is identified by the combination of it's *Layout Name*, *Instance Name* and *Plate Name*.  The names are used to classify and organize plates.

### Layout Name
A class of pages.  For instance, the layout for all help pages.

### Instance Name
A specific page using a layout.  For instance, the contact help page.  The Instance Name can be blank for those layouts that have only one instance, such as a home page.

### Plate Name
A content area on a web page.  For instance, the body of the contact help page.

### Plate Edition
A *Plate* has many *Plate Editions*.  These editions contain content and can be scheduled.

### Fallback Edition
The edition that is published if no scheduled edition can be found.

### Publish
Flag used to mark that an edition is ready to be considered for publishing.  Scheduling rules will take this edition into account.

### Event
*Plate Editions* can be grouped into *Events* that can be scheduled.  All editions take on the Events start time and and time.

### Plate Set
A *Plate Set* is a template for generating a group of related *Plates*.  For example, if a help page has a body plate and a left column plate, a user can generate an instance of both those plates from that plate set.

### Consuming App
The application that makes web calls out to rit. for content.


Scheduling
----------

### Conflicts
When there are scheduling conflicts for multiple editions of the same plate, the *start time* is used to determine which plate gets published.  The event latest start time takes priority.  

If start multiple editions have the same start time, the most recently modified edition takes priority


### Example
                    1     2                  3      4
    Timeline:  <----^-----^------------------^------^---->
    
    edition 1       |-------------------------------|
    edition 2             |------------------|

Edition start times:

 * time 1: edition 1
 * time 2: edition 2
 * time 3: back to edition 1
 * time 4: fallback edition


### Example
                    1     2                  3      4
    Timeline:  <----^-----^------------------^------^---->
    
    edition 1       |------------------------|
    edition 2             |-------------------------|

Edition start times:

* time 1: edition 1
* time 2: edition 2
* time 3: edition 2 continues
* time 4: fallback edition


### Example
                    1     2      3      4    5      6
    Timeline:  <----^-----^------^------^----^------^---->
    
    edition 1       |------------|
    edition 2             |------------------|
    edition 3                           |-----------|

Edition start times:

 * time 1: edition 1
 * time 2: edition 2
 * time 3: edition 2 continues
 * time 4: edition 3
 * time 5: edition 3 continues
 * time 6: fallback edition
 
 
### Example
                    1     2      3      4    5      6
    Timeline:  <----^-----^------^------^----^------^---->
    
    edition 1       |-------------------------------|
    edition 2             |-------------|
    edition 3                     |----------|

Edition start times:

 * time 1: edition 1
 * time 2: edition 2
 * time 3: edition 3
 * time 4: edition 3 continues
 * time 5: back to edition 1
 * time 6: fallback edition
 
 
Publishing
----------

The consuming app can retrieve the current content for a plate from the following URLs:

    http://rit.app/published/<layout name>/<instance name>/<plate name>
    http://rit.app/published/<layout name>/<plate name>


The consuming app can retrieve content on a specific date with:

    http://rit.app/published_on/<layout name>/<instance name>/<plate name>/<epoch time integer>
    http://rit.app/published/<layout name>/<plate name>/<epoch time integer>

NOTE: Retrieving content on a specific date is not currently cached.


Consuming Rit. Content
----------------------

Install the [rit\_client](http://github.com/briandoll/rit_client) Rails plugin into your app.  Follow the configuration instructions specified in the rit_client readme.

For an overview of how to use Rit and rit_client, please see the [Rit. wiki](http://wiki.github.com/briandoll/Rit/).