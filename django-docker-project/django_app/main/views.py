from django.http import JsonResponse, HttpResponse
from django.shortcuts import render


def index(request):
    """Main page view"""
    context = {
        'title': 'Django + Docker + PostgreSQL + Nginx',
        'message': 'Successfully deployed Django application with Docker!'
    }
    return JsonResponse(context)


def health_check(request):
    """Health check endpoint"""
    return HttpResponse('OK', content_type='text/plain')