# Porfolio App
 
The purpose of this app is to track some sort of activity, such as learning Spanish, practicing yoga, or stitching a quilt, so our data falls into two types:

1. A specific __item__ of data we are working on. For example, if our activity was traveling this might be one specific sight we’d like to visit, or if we were tracking a book reading habit then this might be one specific book we want to read.
2. If we put lots of items together, we get a project. For traveling this might be a trip such as “Visit Thailand”, or for books it might be “Books by Agatha Christie”.

So, we created a new core data model to represent these two pieces of data. 

What should a single item have? Well, a few things spring to mind:

1. A title, which is the main name for this item. If our project were to take part in a marathon, we might have item titles like “Complete half marathon in under two hours”.
2. Some optional extra detail, providing any further context for the item if needed. To continue the running example, this might be “I could sign up for the London half marathon” or similar.
3. Some idea of how important this item is relative to the others. For example, “buy running shoes” is high priority if you want to run a marathon, but “convince someone else to take part as well” might be lower priority.
4. Whether the item is completed or not, so it’s clear how far you are through a particular project.
5. When the item was created, so can keep items in a sensible order.

For project:
1. A title for the project, e.g. “Books by Terry Pratchett”.
2. Some optional detail text for the project, providing any extra detail the user wants. For example, this might be “Excluding collaborations”.
3. Whether the project is open (active) or closed (finished).
4. A creation date, so we can store projects in the order they were created.

To make things a little more interesting, we’re going to store another piece of data for projects: a custom color value, representing a simple way for users to differentiate projects using a palette of predetermined colors that look nice.



