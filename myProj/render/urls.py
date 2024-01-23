from django.urls import path
from render import views

urlpatterns = [
    path('', views.index, name='index'),
]