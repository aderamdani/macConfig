Attribute VB_Name = "Module1"
' =====================================================================================
' == MAIL MERGE TO PDF - VERSI OPTIMAL (FINAL FIX 2)
' == Versi: 2.2
' == Deskripsi: Memperbaiki logika loop dengan menambahkan kembali '.ActiveRecord = i'
' ==            untuk memastikan penamaan file sesuai dengan rekor yang diproses.
' =====================================================================================

' --- KONSTANTA GLOBAL ---
Private Const ILLEGAL_FILENAME_CHARS As String = "/\:*?""<>|"
Private Const FOLDER_PROMPT As String = "Pilih folder tujuan untuk menyimpan PDF:"
Private Const FIELD_PROMPT As String = "Masukkan NAMA PERSIS kolom data untuk nama file (Contoh: ID_Pelanggan):"
Private Const FIELD_TITLE As String = "Penamaan File PDF"

' =====================================================================================
' == FUNGSI UTAMA (YANG DIJALANKAN PENGGUNA)
' =====================================================================================
Public Sub JalankanMailMergeKePdf()
    ' --- Inisialisasi ---
    Dim masterDoc As Document
    Dim folderPath As String
    Dim fileNameField As String
    
    On Error GoTo GlobalErrorHandler
    Set masterDoc = ActiveDocument

    ' Memastikan ini adalah dokumen mail merge
    If masterDoc.MailMerge.State = wdNormalDocument Then
        MsgBox "Dokumen ini bukan dokumen mail merge utama.", vbCritical
        Exit Sub
    End If

    ' --- Langkah 1: Dapatkan Input dari Pengguna ---
    folderPath = GetDestinationFolder()
    If folderPath = "" Then Exit Sub ' Pengguna membatalkan

    fileNameField = GetFileNameField(masterDoc)
    If fileNameField = "" Then Exit Sub ' Pengguna membatalkan

    ' --- Langkah 2: Jalankan Proses Inti ---
    PerformMergeLoop masterDoc, folderPath, fileNameField
    
    Exit Sub ' Keluar secara normal

GlobalErrorHandler:
    MsgBox "Terjadi sebuah error yang tidak terduga:" & vbCrLf & vbCrLf & Err.Description, vbCritical, "Proses Dihentikan"
End Sub


' =====================================================================================
' == FUNGSI-FUNGSI PEMBANTU (PRIVATE)
' =====================================================================================

' --- Fungsi untuk mendapatkan folder tujuan dari pengguna ---
Private Function GetDestinationFolder() As String
    Dim chosenPath As String
    
    #If Mac Then
        Dim scriptToRun As String
        scriptToRun = "tell application ""Microsoft Word"" to return POSIX path of (choose folder with prompt """ & FOLDER_PROMPT & """)"
        On Error Resume Next
        chosenPath = MacScript(scriptToRun)
        On Error GoTo 0
    #Else
        With Application.FileDialog(msoFileDialogFolderPicker)
            .Title = FOLDER_PROMPT
            If .Show = -1 Then
                chosenPath = .SelectedItems(1)
            End If
        End With
    #End If
    
    If chosenPath = "" Then
        MsgBox "Operasi dibatalkan. Tidak ada folder yang dipilih.", vbExclamation
    End If
    
    GetDestinationFolder = chosenPath
End Function


' --- Fungsi untuk mendapatkan dan memvalidasi nama kolom dari pengguna ---
Private Function GetFileNameField(ByVal doc As Document) As String
    Dim fieldName As String
    Dim isValid As Boolean
    
    Do
        fieldName = InputBox(FIELD_PROMPT, FIELD_TITLE)
        If fieldName = "" Then
            MsgBox "Operasi dibatalkan. Nama kolom tidak boleh kosong.", vbExclamation
            GetFileNameField = "" ' Kembalikan string kosong jika batal
            Exit Function
        End If
        
        isValid = False
        Dim field As MailMergeDataField
        For Each field In doc.MailMerge.DataSource.DataFields
            If LCase(field.Name) = LCase(fieldName) Then
                isValid = True
                Exit For
            End If
        Next field
        
        If Not isValid Then
            MsgBox "Nama kolom '" & fieldName & "' tidak ditemukan. Harap periksa kembali.", vbExclamation
        End If
    Loop While Not isValid
    
    GetFileNameField = fieldName
End Function


' --- Prosedur Inti untuk Melakukan Proses Merge dan Simpan PDF ---
Private Sub PerformMergeLoop(ByVal masterDoc As Document, ByVal folderPath As String, ByVal fileNameField As String)
    Dim singleDoc As Document
    Dim lastRecordNum As Long
    Dim i As Long
    Dim fullPath As String
    Dim pdfFileName As String
    Dim percentage As Single
    Dim pathSeparator As String

    #If Mac Then
        pathSeparator = "/"
    #Else
        pathSeparator = "\"
    #End If
    
    With masterDoc.MailMerge.DataSource
        .ActiveRecord = wdLastRecord
        lastRecordNum = .ActiveRecord
        .ActiveRecord = wdFirstRecord
    End With

    If MsgBox("Anda akan membuat " & lastRecordNum & " file PDF." & vbCrLf & "Lanjutkan?", vbYesNo + vbQuestion) = vbNo Then
        Exit Sub
    End If
    
    ' --- OPTIMASI DIMULAI ---
    Application.ScreenUpdating = False
    
    masterDoc.MailMerge.Destination = wdSendToNewDocument
    
    For i = 1 To lastRecordNum
        percentage = (i / lastRecordNum) * 100
        Application.StatusBar = "Memproses... " & Format(percentage, "0") & "% Selesai (" & i & " dari " & lastRecordNum & ")"
    
        With masterDoc.MailMerge.DataSource
            .FirstRecord = i
            .LastRecord = i
            .ActiveRecord = i ' <-- (PERBAIKAN) BARIS PENTING INI DITAMBAHKAN KEMBALI
        End With
        
        masterDoc.MailMerge.Execute False
        Set singleDoc = ActiveDocument
        
        pdfFileName = SanitizeFileName(masterDoc.MailMerge.DataSource.DataFields(fileNameField).Value)
        If Trim(pdfFileName) = "" Then
            pdfFileName = "Dokumen_Tanpa_Nama_" & i
        End If

        If Right(folderPath, 1) <> pathSeparator Then
            folderPath = folderPath & pathSeparator
        End If
        
        fullPath = folderPath & pdfFileName & ".pdf"
        
        singleDoc.SaveAs2 fileName:=fullPath, FileFormat:=wdFormatPDF
        singleDoc.Close False
    Next i

    ' --- PEMBERSIHAN ---
    Application.StatusBar = ""
    Application.ScreenUpdating = True
    ' --- OPTIMASI SELESAI ---

    MsgBox "Proses Selesai!" & vbCrLf & vbCrLf & i - 1 & " file PDF telah berhasil dibuat di:" & vbCrLf & folderPath, vbInformation
End Sub


' --- Fungsi utilitas untuk membersihkan nama file ---
Private Function SanitizeFileName(ByVal fileValue As Variant) As String
    Dim fileName As String
    If IsNull(fileValue) Then
        fileName = ""
    Else
        fileName = CStr(fileValue)
    End If
    
    Dim char As Integer
    For char = 1 To Len(ILLEGAL_FILENAME_CHARS)
        fileName = Replace(fileName, Mid(ILLEGAL_FILENAME_CHARS, char, 1), "-")
    Next char
    
    SanitizeFileName = Trim(fileName)
End Function
