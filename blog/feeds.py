from django.contrib.syndication.views import Feed
from django.template.defaultfilters import truncatewords
from django.contrib.sites.models import Site
from .models import Post

domain = Site.objects.get_current().domain

class LatestPostsFeed(Feed):
    title = 'VOKINA BLOG'
    link = '/blog'
    description = 'Последние публикации'

    def items(self):
        return Post.published.all()[:5]

    def item_title(self, item):
        return item.title

    def item_description(self, item):
        return truncatewords(item.body, 30)

  
"""
Returns an extra keyword arguments dictionary that is used with
the `add_item` call of the feed generator.
Add the 'content' field of the 'Entry' item, to be used by the custom feed generator.
"""
