from django.contrib.auth import views as auth_views
from django.views.generic import TemplateView, RedirectView
from django.contrib import admin
from django.urls import path, include, reverse_lazy
from django.conf import settings
from django.conf.urls.static import static

from .views import login_view, register_view


urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('documents.urls')),
    path("accounts/login/", login_view, name='login'),
    path('accounts/register/', register_view, name='register'),
    path("accounts/profile/", RedirectView.as_view(url=reverse_lazy('main'))),
]
urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
