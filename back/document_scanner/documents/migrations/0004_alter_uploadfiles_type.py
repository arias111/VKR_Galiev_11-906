# Generated by Django 4.1.7 on 2023-03-28 19:13

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('documents', '0003_uploadfiles_type'),
    ]

    operations = [
        migrations.AlterField(
            model_name='uploadfiles',
            name='type',
            field=models.CharField(blank=True, choices=[('Документ', 'Документ'), ('МК', 'МК'), ('Виза', 'Виза')], max_length=255, null=True, verbose_name='Тип документа'),
        ),
    ]
