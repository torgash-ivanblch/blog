# Generated by Django 2.0.3 on 2018-03-25 14:46

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('blog', '0004_post_tags'),
    ]

    operations = [
        migrations.AddField(
            model_name='post',
            name='pic',
            field=models.FileField(default='', upload_to='images/%Y/%m/%d/'),
        ),
    ]
