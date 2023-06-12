from django.db import models
from django.contrib.auth import get_user_model


User = get_user_model()


class UploadFiles(models.Model):
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        verbose_name="Пользователь"
    )

    files = models.FileField(
        upload_to='upload_files/',
        blank=True,
        null=True
    )

    type = models.CharField(
        'Тип документа',
        max_length=255,
        choices=(
            ('Документ', 'Документ'),
            ('МК', 'МК'),
            ('Виза', 'Виза'),
        ),
        null=True,
        blank=True,
    )


class ResultFiles(models.Model):
    upload_file = models.OneToOneField(
        UploadFiles,
        on_delete=models.CASCADE,
    )

    scan_png = models.FileField(
        upload_to='scan_png/',
        blank=True,
        null=True
    )

    scan_pdf = models.FileField(
        upload_to='scan_pdf/',
        blank=True,
        null=True
    )
