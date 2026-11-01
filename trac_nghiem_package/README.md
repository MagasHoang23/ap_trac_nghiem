# Hệ thống Trắc nghiệm Ôn luyện (Quiz Practice App)

Ứng dụng web ôn luyện trắc nghiệm hiện đại, gọn gàng, hỗ trợ biên dịch tự động định dạng phong phú (in đậm, in nghiêng, cỡ chữ, thụt lề phân cấp, danh sách, khối ghi chú, màu sắc) và cơ chế tự động hóa đẩy mã nguồn lên GitHub.

---

## 🌟 Tính năng nổi bật

* **Giao diện hiện đại & Thân thiện**: Tối ưu hiển thị trên cả máy tính và điện thoại di động.
* **Bộ giải thích Card sang trọng**: Phần giải thích được định dạng rõ ràng, tách bạch từng luận điểm, hiển thị ngay tại ô đáp án đúng (và lý do sai nếu có).
* **Biên dịch định dạng phong phú (Rich Text)**:
  * **In đậm / In nghiêng**: `**đậm**`, `*nghiêng*`, `[b]...[/b]`, `[i]...[/i]`.
  * **Cỡ chữ & Tiêu đề**: `# Tiêu đề lớn`, `## Tiêu đề vừa`, `### Tiêu đề nhỏ`, `[to]...[/to]`, `[nho]...[/nho]`.
  * **Thụt lề phân cấp (Indentation)**: 2 hoặc 4 dấu cách đầu dòng để thụt lề kèm vạch định hướng lề (*indent guide*).
  * **Danh sách & Mũi tên**: `- `, `* `, `1. `, `-> `, `=> `.
  * **Ghi chú & Màu sắc**: `> Ghi chú`, `==highlight==`, `[do]đỏ[/do]`, `[xanh]xanh[/xanh]`, `[cam]cam[/cam]`.
  * **Công thức / Code**: `` `công thức` ``.
* **Máy trạng thái phân tích đề thi thông minh (`parseNewQuizData`)**: Hỗ trợ đề bài nhiều dòng, giải thích nhiều dòng, nhận diện linh hoạt các tiền tố câu và đáp án.
* **Modal nạp đề có Live Preview**: Cho phép xem trước kết quả biên dịch câu hỏi và giải thích trước khi bắt đầu làm bài.
* **Tự động lưu bài & Xem lại lịch sử**: Khôi phục trạng thái làm bài khi tải lại trang, lưu trữ snapshot 20 lần thi gần nhất.

---

## 🚀 Tự động Commit & Push lên GitHub

Dự án tích hợp sẵn script tự động hóa hoàn toàn để bạn hoặc bất kỳ Trợ lý AI nào cũng có thể tự động đẩy code:

### Cách thiết lập nhanh (Chỉ làm 1 lần):
1. Tạo một GitHub Personal Access Token (Classic) có quyền `repo` tại:
   👉 [https://github.com/settings/tokens](https://github.com/settings/tokens)
2. Lưu token bằng một trong hai cách:
   * **Cách A (Khuyên dùng)**: Tạo file `.env` cạnh `auto_push.py` với nội dung:
     ```env
     GITHUB_TOKEN=ghp_chuoi_token_cua_ban
     ```
   * **Cách B (Qua lệnh)**:
     ```bash
     python auto_push.py -t "ghp_chuoi_token_cua_ban" --save-token
     ```

### Cách đẩy code tự động:
Mỗi khi có thay đổi code, chỉ cần chạy một lệnh:
```bash
python auto_push.py -m "Nội dung commit của bạn"
```
Hoặc dùng PowerShell:
```powershell
.\auto_push.ps1 -Message "Nội dung commit của bạn"
```
Script sẽ tự động: `git add .` -> `git commit` -> `git push` lên nhánh `main` mà không cần bất kỳ thao tác thủ công nào.

---

## 🤖 Dành cho các Trợ lý AI (AI Assistants)

Vui lòng tham khảo file [`SKILL.md`](./SKILL.md) trong gói này để biết đầy đủ:
* Các điều kiện tiên quyết và cách kiểm tra môi trường.
* Quy chuẩn định dạng đề và giải thích.
* Cách tự động hóa toàn bộ chu trình phát triển và triển khai cho người dùng.

---

## 📂 Cấu trúc thư mục

```text
├── index.html         # Mã nguồn chính của ứng dụng web
├── auto_push.py       # Script Python tự động Commit & Push lên GitHub
├── auto_push.ps1      # Script PowerShell tự động Commit & Push cho Windows
├── .env.example       # File mẫu cấu hình GitHub Token
├── .gitignore         # Danh sách loại trừ file nhạy cảm và tạm
├── SKILL.md           # Hướng dẫn chi tiết cho các Trợ lý AI khác
└── README.md          # Hướng dẫn sử dụng tổng quan
```

