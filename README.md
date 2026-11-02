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


---

### ✨ Tính Năng Mới Nâng Cao:
1. **Đồng bộ đám mây Google Drive (Serverless Cloud Sync)**:
   - Đăng nhập/Đăng ký tài khoản và mật khẩu bảo vệ.
   - Dữ liệu câu hỏi, tiến trình làm bài và lịch sử thi được lưu trữ trực tiếp trên tài khoản Google Drive cá nhân của người dùng (`ap_trac_nghiem_cloud_backup.json`).
   - Mã hóa bảo mật đầu cuối bằng chuẩn **AES-GCM 256-bit + PBKDF2 (100,000 vòng lặp)**. Chỉ người có đúng mật khẩu mới giải mã được.
   - Cơ chế đồng bộ ngầm tự động (Background Auto-sync): debounce thông minh 8s khi làm bài, đồng bộ tức thời khi nộp bài hoặc nạp đề mới, và nhịp tim định kỳ mỗi 45s.
2. **Căn chỉnh giao diện linh hoạt (Responsive Display Controls)**:
   - Tùy chỉnh kích thước cỡ chữ 4 cấp độ: `A-` (nhỏ), `A` (chuẩn), `A+` (lớn), `A++` (rất lớn).
   - Tùy chỉnh căn lề: Căn trái hoặc Căn đều hai bên (`justify`).
   - Nút thu gọn danh sách câu hỏi trên điện thoại để tối ưu không gian đọc bài.
3. **Trải nghiệm di động hoàn hảo (Anti-Zoom Mobile Fix)**:
   - Khắc phục triệt để lỗi tự động phóng to màn hình khi mở modal thiết lập đề thi trên điện thoại (đảm bảo `font-size: 16px !important` cho tất cả ô nhập liệu).


4. **Định dạng Gạch chân & Đồng bộ đáp án chống lệch**:
   - Hỗ trợ cú pháp gạch chân `<u>...</u>`, `++...++`, `[u]...[/u]`.
   - Nút `A/1` chuyển đổi thẻ đáp án `A, B, C, D` và `1, 2, 3, 4`.
   - Nút `🔀` Bật/Tắt xáo trộn đáp án.
   - Cơ chế tự động đồng bộ câu kết luận trong giải thích khớp với vị trí hiển thị thực tế trên màn hình.

5. **Đồng bộ thời gian thực siêu tốc (<100ms) - Dual-Engine Live Sync**:
   - Tương tác đồng thời giữa 2 thiết bị (điện thoại & máy tính): Ấn chọn đáp án, cắm cờ hoặc làm lại đề trên điện thoại -> Màn hình máy tính lập tức nhảy màu xanh/đỏ, mở giải thích chi tiết trong tích tắc (< 100 mili-giây).
   - Thông báo nổi tương tác (*Live Sync Toast*): Hiển thị thông báo khi có thao tác từ thiết bị khác kèm nút xem nhanh câu hỏi đó.
   - Cơ chế bảo mật tuyệt đối: Kênh truyền thông được mã hóa đầu cuối bằng thuật toán AES-GCM 256-bit và định danh kênh theo SHA-256(Email + Mật khẩu).
   - Lưu trữ song song bền vững trên Google Drive: Toàn bộ tiến trình tự động sao lưu vào Drive sau mỗi 1.5 giây.

   - **Nút "📲 Đồng bộ 2 máy"**: Khi 2 máy đang mở 2 đề thi khác nhau (ví dụ: máy tính 30 câu, điện thoại 25 câu), người dùng chỉ cần bấm nút `📲 Đồng bộ 2 máy` -> `Đẩy bộ đề máy này sang máy kia` để cả 2 thiết bị lập tức chuyển về cùng một bộ đề 100% trong tích tắc.
   - **Tự động chuyển câu song song (Follow Navigation)**: Bật/Tắt chế độ tự động lật câu hỏi trên máy tính mỗi khi bạn bấm chuyển câu trên điện thoại.
