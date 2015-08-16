---
layout: post
title: Start a tech blog using Jekyll Part I
description: "You want to start blogging but not sure how? This step by step should guide you through the process of starting your own blog using Github pages and Jekyll"
introduction: "You want to start blogging but not sure how? This step by step should guide you through the process of starting your own blog using Github pages and Jekyll"
category: blog
tags: [blog, jekyll, github-pages]
comments: true
image:
    feature: start-a-tech-blog-using-jekyll/blog-1024x768.jpg
---

# Choosing the platform

Every time you start a new project you should first consider which tools are at your disposal, evaluate them and try to use the right one for the job at hand. Often times though, is easy to get swamped by the amount of available tools out there. One way that helps me triaging amongst them is to come up with a list of requirements that the tool should allow you to do. In my case they were:

- It has to be **simple**
- Allow for **static** content generation. No need of using a DB
- **Markdown support**. Having a standard format helps greatly for editing and content migrations
- **Code highlighting**. We're gonna be talking code at the end of the day, right?
- Pre-baked **themes**. Yeah, I suck at front-end ;)

With that in mind, I discarded few obvious choices like Wordpress or Blogger. I've hosted blogs on those platforms before and although they might seem simple at first, they can become a real pain to maintain.

I also considered other options like Ghost + Buster or Sculpin, but I ended up choosing Jekyll because it ticked all the boxes, it is extremely simple and it has massive adoption.

# Setting things up

Hosting your own page using [Github Pages](https://pages.github.com/) is quite straight forward. Just follow their instructions to set up your repository and you will get a hello world page up in a matter of seconds!
 
Part of the beauty of this way of blogging is that everything is in source control, allowing you to easily rollback to whichever version you see fit very quickly. You can deploy as often as you like by simply pushing your master branch.
 
Github Pages provides support for Jekyll by default. [Jekyll](http://jekyllrb.com/docs/quickstart/) is an engine which generates static sites based on few configuration and content files. Again, you just need to follow the [installation](http://jekyllrb.com/docs/installation/) steps to get all the necessary tools ready on your machine to start generating content.

If everything is installed correctly, you should be able to run a Jekyll web server locally, which will monitor your project and re-build your site every time a change occurs. That is except if changes are in the "\_config.yml" file (which we will discuss in a minute). If they are, you will need to re-start the local server manually. To start the server just type:

{% highlight text %}
jekyll serve
{% endhighlight %}

You should be able to access your site by visiting "http://localhost:4000/" in your browser.

# Make it your own

## Theming
Once the tools are ready, you just need to start creating content... but starting from scratch can be a bit daunting. That's why I think the best way to start is to pick an already cooked theme and tweak it to your liking.
 
There are many [themes](https://github.com/jekyll/jekyll/wiki/Themes) [available](http://drjekyllthemes.github.io/) for you to choose from. Since I like big pictures and big fonts, I chose [Balzac](http://jekyll.gtat.me/about/) from [@twnsndco](https://twitter.com/twnsndco).

## Configuration
Next step is to set the values in the "\_config.yml" file. This file contains some configuration values that are used by Jekyll when building the site. Here are some interesting ones:

{% highlight yaml %}
#Canonical URL
canonical:        http://www.hasumedic.com

# Which highlighter and markdown libraries to use to evaluate and transform your content
highlighter: pygments
markdown:    kramdown

# Which files to include/exclude when building the static site
include: [".nojekyll"]
exclude: ["lib", "config.rb", "Capfile", "config", "log", "_plugins", "tmp", "publish.sh"]
{% endhighlight %}

You can find more configuration options for your "\_config.yml" in [here](http://jekyllrb.com/docs/configuration).

But it's not only about default configuration values. You can also define your own variables as well which will then become available to the template engine under the variable "site".

{% highlight yaml %}

owner:
  # This value will be available in your templates as "site.owner.twitter"
  twitter:        hasumedic

# You can set your 3rd party configuration values in here too
analytics:
  google:
    tracking_id: "UA-1234567890-0"
    
{% endhighlight %}

## Front-end
After this, is the moment to play around with HTML and CSS for a while, until you get every page looking like you want. It's important to have a look at [Jekyll's directory structure](http://jekyllrb.com/docs/structure/) to get an understanding of what's going on.

The "\_posts" folder is the one that Jekyll looks at to find your markdown posts. Starting a new post is as easy as to creating a new file in it, naming it following the convention: "YYYY-mm-dd-{name-of-your-post)].md".

There's the option to also use the "\_drafts" folder. This folder contains your WIP for the blog. In combination with libraries such as [jekyll-compose](https://github.com/jekyll/jekyll-compose) you can get a nice little workflow for writing and publishing posts.

Another key directory to take into consideration is the "\_layout". Here you can define the structure of your pages to provide a certain structure to your pages and facilitate re-usability. Then, using [Front Matter](http://jekyllrb.com/docs/frontmatter/), you can quickly set up the layout and specific information of your posts like:

{% highlight text %}
---
layout: post
title: Start a tech blog using Jekyll
description: "You want to start blogging but not sure how? This step by step should guide you through the process of starting your own blog using Github pages and Jekyll"
category: blog
tags: [blog, jekyll, github-pages]
comments: true
image:
    feature: start-a-tech-blog-using-jekyll/blog-1024x768.jpg
---
{% endhighlight %}

If I wanted to disable the comments for this page, I'd only need to change the "comments" flag to false. Changing the layout to "post-no-feature" would ignore the feature image at the top of the post. And so on.

Finally, the "_includes" folder contains those blocks of HTML that you want to re-use in your different layouts. Think of header, footer, GA, comments section, sharing bars, etc.

# Deploying

As I mentioned before, deploying your blog is as easy as to pushing your master branch. Github pages will automatically run Jekyll on your repository, and will generate the static content in a folder called "\_site" as per default. 

You'll note though, that when you access your site you'll need to do it on {your_github_name}.github.io/_site/. If you don't want that to happen, just generate your content at your repository's root level.

You can change where this content gets generated in your "\_config.yml":
{% highlight text %}
    destination: {your_location_here}
{% endhighlight %}

You could think on using something like htaccess or similar, but they are disabled in Github pages for security reasons.


In the next post, I'll explain how you can add some extra stuff to your blog like a recent posts section, GA or comments. Also, another way to handle the deployment of the blog.
