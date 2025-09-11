"""
URL configuration for django_app project.
"""

from django.contrib import admin
from django.urls import path
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

def home_view(request):
    """Home page view"""
    return JsonResponse({
        'message': 'Successfully deployed Django application with Docker!',
        'status': 'healthy',
        'version': '1.0.0'
    })

def health_view(request):
    """Health check endpoint"""
    return JsonResponse({
        'status': 'healthy',
        'database': 'connected'
    })

urlpatterns = [
    path("admin/", admin.site.urls),
    path("", home_view, name="home"),
    path("health/", health_view, name="health"),
]