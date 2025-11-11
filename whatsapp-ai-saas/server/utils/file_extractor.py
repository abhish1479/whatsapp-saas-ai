"""
FileExtractor Service
---------------------
A centralized, static class to extract raw text content from various file types.

This service is used by the RAG processing worker to convert binary files
(PDFs, DOCX, Excel, etc.) into a simple string format that can be
chunked and fed to an LLM.
"""

import os
import io
import pandas as pd
import fitz  # PyMuPDF
import docx  # python-docx
from typing import Dict, Callable

class UnsupportedFileTypeError(Exception):
    """Custom exception for files we can't process."""
    pass

class FileExtractor:
    """
    A static class that routes file content to the correct text extractor
    based on MIME type or file extension.
    """

    # --- Private Extraction Methods ---

    @staticmethod
    def _extract_simple_text(file_bytes: bytes) -> str:
        """Extracts text from simple text-based files (txt, csv, md, etc.)."""
        try:
            text = file_bytes.decode('utf-8')
            text = text.replace("\r\n", "\n").replace("\x00", "")
            return text
        except UnicodeDecodeError:
            # Fallback for non-utf8 files
            return file_bytes.decode('latin-1', errors='replace')

    @staticmethod
    def _extract_pdf(file_bytes: bytes) -> str:
        """Extracts all text from a PDF document."""
        text_content = []
        try:
            with fitz.open(stream=file_bytes, filetype="pdf") as doc:
                for page in doc:
                    text_content.append(page.get_text())
            return "\n\n".join(text_content) # Separate pages
        except Exception as e:
            print(f"Error processing PDF: {e}")
            return "" # Return empty string on failure

    @staticmethod
    def _extract_excel(file_bytes: bytes) -> str:
        """
        Extracts content from an Excel file (.xls or .xlsx).
        Converts each sheet to a CSV-like string and joins them.
        """
        all_text_content = []
        try:
            with io.BytesIO(file_bytes) as f:
                # Use pandas to read all sheets
                xls = pd.ExcelFile(f)
                for sheet_name in xls.sheet_names:
                    df = pd.read_excel(xls, sheet_name=sheet_name, header=None)
                    # Convert dataframe to a simple, token-efficient string
                    sheet_text = df.to_string(index=False, header=False, na_rep="")
                    
                    all_text_content.append(
                        f"--- Sheet: {sheet_name} ---\n{sheet_text}\n\n"
                    )
            return "".join(all_text_content)
        except Exception as e:
            print(f"Error processing Excel file: {e}")
            return ""

    @staticmethod
    def _extract_docx(file_bytes: bytes) -> str:
        """Extracts all text from a .docx file."""
        text_content = []
        try:
            with io.BytesIO(file_bytes) as f:
                doc = docx.Document(f)
                for para in doc.paragraphs:
                    text_content.append(para.text)
            return "\n".join(text_content)
        except Exception as e:
            print(f"Error processing DOCX file: {e}")
            return ""

    # --- Type-to-Method Mapping ---
    # This acts as a router.
    
    # We prioritize MIME types as they are more reliable than extensions.
    MIME_TYPE_MAP: Dict[str, Callable[[bytes], str]] = {
        'text/plain': _extract_simple_text,
        'text/csv': _extract_simple_text,
        'application/pdf': _extract_pdf,
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': _extract_excel, # .xlsx
        'application/vnd.ms-excel': _extract_excel, # .xls
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document': _extract_docx, # .docx
    }

    # Fallback for when MIME type is generic (e.g., 'application/octet-stream')
    EXTENSION_MAP: Dict[str, Callable[[bytes], str]] = {
        '.txt': _extract_simple_text,
        '.csv': _extract_simple_text,
        '.md': _extract_simple_text,
        '.json': _extract_simple_text,
        '.py': _extract_simple_text,
        '.pdf': _extract_pdf,
        '.xlsx': _extract_excel,
        '.xls': _extract_excel,
        '.docx': _extract_docx,
    }


    # --- Public Main Method ---

    @staticmethod
    def extract_text(file_bytes: bytes, filename: str) -> str:
        """
        Extracts text content from file bytes.

        It first tries to find a handler using the provided MIME type.
        If that fails or the MIME type is generic, it falls back to
        using the file extension from the filename.

        Args:
            file_bytes: The raw bytes of the file.
            mime_type: The MIME type of the file (e.g., 'application/pdf').
            filename: The original filename (e.g., 'report.pdf').

        Returns:
            A string containing the extracted text content.

        Raises:
            UnsupportedFileTypeError: If the file type is not supported.
        """
        handler = None
        # 1. Try to find handler by a specific MIME type
        # handler = FileExtractor.MIME_TYPE_MAP.get(mime_type)

        # 2. If no match or generic MIME, try fallback to file extension
        if not handler:
            extension = os.path.splitext(filename)[1].lower()
            handler = FileExtractor.EXTENSION_MAP.get(extension)

        # 3. If still no handler, we can't process this file
        if not handler:
            raise UnsupportedFileTypeError(
                f"Unsupported file type: {filename}"
            )
        
        # 4. Call the appropriate handler (e.g., _extract_pdf)
        print(f"Extracting text using handler: {handler.__name__}")
        return handler(file_bytes)