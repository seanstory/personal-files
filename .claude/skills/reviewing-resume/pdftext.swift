// Prints a PDF's text page by page, so reviewers can see what lands on page 1.
// Usage: swift .claude/skills/reviewing-resume/pdftext.swift resume/out/<name>.pdf
// macOS only (PDFKit); no other PDF tools are assumed to be installed.
import PDFKit

let doc = PDFDocument(url: URL(fileURLWithPath: CommandLine.arguments[1]))!
for i in 0..<doc.pageCount {
    print("--- page \(i + 1)")
    print(doc.page(at: i)?.string ?? "")
}
