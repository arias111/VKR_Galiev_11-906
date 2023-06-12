from django.http import HttpRequest, HttpResponse

from django.contrib.auth import authenticate, login
from django.shortcuts import render, redirect

from documents.helpers import convert_image, predict
from .forms import FileUpload
from .models import ResultFiles, UploadFiles
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.decorators import login_required
from django.http import JsonResponse, HttpResponse
import logging


@csrf_exempt
@login_required
def upload_file(request: HttpRequest):
    files = None
    if request.method == "POST":
        form = FileUpload(request.POST, request.FILES)
        files = request.FILES.getlist("files_upload")
        res: list[ResultFiles] = []
        if form.is_valid():
            for f in files:
                file_instance = UploadFiles(files=f)
                file_instance.user = request.user
                file_instance.save()
                res.append(convert_image(file_instance))
                file_instance.type = predict(file=file_instance.files.path)
                file_instance.save()

        res = [
            {
                "original": str(el.upload_file.files.url),
                "scan_png": str(el.scan_png.url),
                "scan_pdf": str(el.scan_pdf.url),
                "type": str(el.upload_file.type),
            }
            for el in res
        ]
        import logging

        logging.warning(res)

        return JsonResponse({"result": res})
    return redirect("main")


@csrf_exempt
@login_required
def main(request: HttpRequest):
    form = FileUpload()
    if request.method == "POST":
        form = FileUpload(request.POST, request.FILES)
        files = request.FILES.getlist("files_upload")
        if form.is_valid():
            res: list[ResultFiles] = []
            for f in files:
                file_instance = UploadFiles(files=f)
                file_instance.user = request.user
                file_instance.save()
                res.append(convert_image(file_instance))
                file_instance.type = predict(file=file_instance.files.path)
                file_instance.save()
    return render(
        request,
        "upload_file.html",
        {
            "form": form,
            "files": UploadFiles.objects.filter(user=request.user).all()[::-1],
        },
    )


def get_result_files(data: dict, el: UploadFiles):
    scan = {
        "scan_png": "",
        "scan_pdf": "",
    }
    try:
        scan["scan_png"] = str(el.resultfiles.scan_png.url)
        scan["scan_pdf"] = str(el.resultfiles.scan_pdf.url)

    except UploadFiles.resultfiles.RelatedObjectDoesNotExist:
        pass

    data.update(scan)

    return data


@login_required
def my_uploads(request: HttpRequest):
    res: list[UploadFiles] = UploadFiles.objects.filter(
        user=request.user
    ).all()[::-1]

    res = [
        get_result_files(
            {
                "original": str(el.files.url),
                "type": str(el.type),
            },
            el,
        )
        for el in res
    ]

    return JsonResponse({"result": res})
