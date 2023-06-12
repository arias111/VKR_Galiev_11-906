from django.urls import path
from . import views


urlpatterns = [
    path('', views.main, name='main'),
    path('upload/', views.upload_file, name='upload_file'),
    path('my_uploads/', views.my_uploads, name='my_uploads'),
]
