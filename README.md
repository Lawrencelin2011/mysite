# 新專案開始建立的方式 (cmd 系統管理員)：

## [1] 建立專案 目錄，並且 到 專案目錄去:

```
C:\GitProjects>md mysite
C:\GitProjects>cd mysite
```

## [2] 檢查是不是有 您要的 Python 版本：
```
py -0p
```
C:\GitProjects\mysite>py -0p
 -V:3.11 *        C:\Users\mojtpm\AppData\Local\Programs\Python\Python311\python.exe
 -V:3.9           C:\ProgramData\Anaconda3\python.exe
 -V:3.8           C:\Users\mojtpm\AppData\Local\Programs\Python\Python38\python.exe
 -V:3.7           C:\Users\mojtpm\AppData\Local\Programs\Python\Python37\python.exe
 -V:ContinuumAnalytics/Anaconda39-64 C:\ProgramData\Anaconda3\python.exe

 (如果沒有您要的版本，則要去下載，並且 Set-Up)
 (這裡要使用 V3.11 -- 目前Render 只吃這個版本，另外，Django 5.0 也吃這個版本)

## [3] 建立 venv, 並且 Activate 這個 venv:
```
py -3.11 -m venv venv
.\venv\Scripts\activate
```
(venv) C:\GitProjects\mysite>

（使用 V3.11)

## [4] Initial poetry:
```
poetry init 
```
This command will guide you through creating your pyproject.toml config.

Package name [mysite]:
Version [0.1.0]:
Description []:
Author [Lawrence Lin <lawrencelin2011@gmail.com>, n to skip]:
License []:
Compatible Python versions [^3.9]:  ^3.11

Would you like to define your main dependencies interactively? (yes/no) [yes] n
Would you like to define your development dependencies interactively? (yes/no) [yes] n
Generated file

[tool.poetry]
name = "mysite"
version = "0.1.0"
description = ""
authors = ["Lawrence Lin <lawrencelin2011@gmail.com>"]
readme = "README.md"

[tool.poetry.dependencies]
python = "^3.11"


[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"


Do you confirm generation? (yes/no) [yes]

## [5] 把 Django 加到 poetry 去。 （類似 pip install django )
```
poetry add django
```

## [6] 建立 Django 框架 ( 1. startproject, 2.startapp):
```
django-admin startproject myProj
cd myProj
python manage.py startapp render
```

## [7] Django 的 基本建立操作：
```
一. myProj 設定
1. 通知 Django 我們的 新 application 上來囉
   在 [myProj/settings.py] , 加上 " 'render.apps.RenderConfig', "
   # Application definition
    INSTALLED_APPS = [
        'render.apps.RenderConfig',
        "django.contrib.admin",
2. 通知 root url 分配器，要分配到哪裡去 :
   在[myProj/urls.py], 加上
   多 import include， 
   並且, 讓 root 的 url include " render下面的 urls.py"

    from django.urls import path, include
    urlpatterns = [
        path("admin/", admin.site.urls),
        path('', include('render.urls')),
    ]
二. render 設定
1. 建立 Render 的 view:
   在 [render/views.py], 加上
   # Create your views here.
    def index(request):
        return render(request, 'render/index.html', {})
2. 建立 Render 這個 app 所 mapping 的 urls:
   建立 [render/urls.py] 
    from django.urls import path
    from render import views
    urlpatterns = [
        path('', views.index, name='index'),
    ]

3. 加上一張 static image：
   在 [render/static/render/render.png:]
   記得要在 下面的 template 中，load static "{% load static %}"; 然後，這張 static 可以在 其他地方使用: (參考 下步驟 4)
   <header class="container mt-4 mb-4">
        <a href="https://render.com">
            <img src="{% static "render/render.png" %}" alt="Render" class="mw-100">
        </a>
    </header>

4. 建立 render/index.html
   在 [render/templates/render/index.html]

    {% load static %}

    <!doctype html>
    <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />

            <title>Hello Django on Render!</title>

            <link rel="stylesheet"
                href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css"
                integrity="sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk"
                crossorigin="anonymous">
        </head>
        <body>
            <header class="container mt-4 mb-4">
                <a href="https://render.com">
                    <img src="{% static "render/render.png" %}" alt="Render" class="mw-100">
                </a>
            </header>
            <main class="container">
                <div class="row text-center justify-content-center">
                    <div class="col">
                        <h1 class="display-4">Hello World!</h1>
                    </div>
                </div>
            </main>
        </body>
    </html>

```

## [7] 建立 Render app， poetry 需要額外的 3 個東西, 4 個 apk : 
```
    1. Render Database - postgresql（DJ_Database_url 與  psycopg2-binary ) 
        poetry add dj-database-url psycopg2-binary
    2. Copy static 檔案， 所需要的 apk ( whitenoise )
        poetry add whitenoise
    3. 啟動 web 的 wsig runtime ( Gunicorn )
        poetry add gunicorn
```

## [8] 設定 3 個東西(都在 seetings.py 裡面) 
    在 [mysite/settings.py]（ 記得要 import os )
    1. SECRET_KEY， 要從 環境變數取得
        SECRET_KEY = os.environ.get('SECRET_KEY', default='your secret key')
    2. DEBUG 要關掉
        DEBUG = 'RENDER' not in os.environ
    3. 設定 HOST ID
        RENDER_EXTERNAL_HOSTNAME = os.environ.get('RENDER_EXTERNAL_HOSTNAME')
        if RENDER_EXTERNAL_HOSTNAME:
            ALLOWED_HOSTS.append(RENDER_EXTERNAL_HOSTNAME) 

## [9] 建立 Render 提供的 PostgreSQL:
```
    在 [mysite/settings.py] 的 DATABASE 這邊:
    import dj_database_url

    # Database
if DEBUG :
    DATABASES = {
    "default": 
        {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": BASE_DIR / "db.sqlite3",
        }
    }
else:
    DATABASES = {
    'default': dj_database_url.config(
        # Feel free to alter this value to suit your needs.
        default='postgresql://postgres:postgres@localhost:5432/mysite',
        conn_max_age=600
        )
    }
```

## [10] 加上  middleware（whitenoise） 給 static 用， 並且建立 static 的 copy code
```
1. 在 [mysite/settings.py] 的 MIDDLEWARE 這邊:
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    ...
]
2. 在 [mysite/settings.py] 的 STATIC_URL = '/static/' 這邊:

# Following settings only make sense on production and may break development environments.
if not DEBUG:
    # Tell Django to copy statics to the `staticfiles` directory
    # in your application directory on Render.
    STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

    # Turn on WhiteNoise storage backend that takes care of compressing static files
    # and creating unique names for each version so they can safely be cached forever.
    STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'
```
## [11] 建立 Render 需要的 build.sh 與 yaml 檔
```
放在 根目錄 ( 跟 pyproject.toml 同等級 )
1. build.sh:
#!/usr/bin/env bash
# exit on error
set -o errexit

poetry install

python manage.py collectstatic --no-input
python manage.py migrate

2. render.yaml
databases:
  - name: mysite
    databaseName: mysite
    user: mysite
    plan: free

services:
  - type: web
    name: mysite
    plan: free
    runtime: python
    buildCommand: "./build.sh"
    startCommand: "gunicorn mysite.wsgi:application"
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: mysite
          property: connectionString
      - key: SECRET_KEY
        generateValue: true
      - key: WEB_CONCURRENCY
        value: 4

```

## [12] 建立 Render 的 yaml 檔.
```
    

```