from flask import Flask, request, jsonify
import pytesseract
from PIL import Image
import io

app = Flask(__name__)

pytesseract.pytesseract.tesseract_cmd = r'D:\Programs\Tesseract-OCR\tesseract.exe'

def perform_ocr(image):
    try:
        text = pytesseract.image_to_string(image)

        return text
    except Exception as e:
        return str(e)

@app.route('/api/ocr', methods=['POST'])
def ocr_endpoint():
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image file provided'})

        image_file = request.files['image']

        image = Image.open(io.BytesIO(image_file.read()))

        result_text = perform_ocr(image)

        return jsonify({'result': result_text})
    except Exception as e:
        return jsonify({'error': str(e)})

if __name__ =="__main__":
    app.run(debug=True)