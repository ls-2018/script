docker rm pdf2zh --force
docker run -d --name pdf2zh -p 7860:7860 byaidu/pdf2zh
