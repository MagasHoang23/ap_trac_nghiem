---
name: quiz-app-auto-deploy
description: "Hướng dẫn trợ lý AI tự động bảo trì, kiểm thử định dạng đề thi và tự động Commit & Push mã nguồn ứng dụng Trắc Nghiệm lên GitHub."
---

# KỸ NĂNG: QUẢN LÝ & TỰ ĐỘNG HÓA DỰ ÁN TRẮC NGHIỆM (QUIZ APP)

Tài liệu này được thiết kế để bất kỳ **Trợ lý AI nào** (Google Antigravity, Claude Code, GitHub Copilot, Cursor, ChatGPT, Gemini CLI...) khi tiếp nhận dự án đều nắm được toàn bộ quy trình vận hành, phát triển và cơ chế **tự động đẩy mã nguồn lên GitHub** mà không bị gián đoạn.

---

## 1. YÊU CẦU ĐỐI VỚI AI (AI PREREQUISITES & CAPABILITIES)

Để AI có thể tự động chỉnh sửa và đẩy mã nguồn lên GitHub thành công, AI cần các công cụ và thông tin sau:

### 1.1. Công cụ cần có:
1. **Quyền chạy lệnh hệ thống (Terminal/Shell)**:
   * Cho phép chạy `python` hoặc `powershell`.
2. **Trình thông dịch Git (`git.exe`)**:
   * Kiểm tra bằng lệnh: `git --version`
   * Nếu Git không có sẵn trong biến môi trường `$env:PATH` trên Windows, AI phải tự tìm Git tại các đường dẫn mặc định:
     - `C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Git\cmd\git.exe`
     - `C:\Program Files\Git\cmd\git.exe`
     - `%LOCALAPPDATA%\Programs\Git\cmd\git.exe`

### 1.2. Thông tin xác thực GitHub (Authentication):
* Trong môi trường nền (non-interactive / headless shell), lệnh `git push` mặc định sẽ bị treo hoặc thất bại nếu Git Credential Manager cố mở cửa sổ giao diện GUI để yêu cầu đăng nhập.
* **Giải pháp**: AI cần một **GitHub Personal Access Token (PAT)** có quyền `repo`.
* **Cách AI lấy Token**:
  1. Kiểm tra biến môi trường: `$env:GITHUB_TOKEN` hoặc `$env:GH_TOKEN`.
  2. Kiểm tra file `.env` hoặc `.github_token` trong thư mục dự án: `GITHUB_TOKEN=ghp_xxxx`.
  3. **Nếu chưa có Token**: AI hãy yêu cầu người dùng cung cấp theo mẫu sau:
     > *"Để tôi có thể tự động đẩy code lên GitHub cho bạn, bạn vui lòng tạo một GitHub Personal Access Token (Classic) có quyền `repo` tại [github.com/settings/tokens](https://github.com/settings/tokens) và gửi cho tôi hoặc lưu vào file `.env` (GITHUB_TOKEN=ghp_...)."*

---

## 2. CƠ CHẾ TỰ ĐỘNG ĐẨY LÊN GITHUB (AUTO-PUSH WORKFLOW)

Dự án đã tích hợp sẵn 2 script tự động hóa hoàn toàn việc `git add`, `git commit`, và `git push`:
* `auto_push.py` (Khuyên dùng - Độc lập nền tảng, tự tìm Git và Token).
* `auto_push.ps1` (Script PowerShell cho Windows).

### 2.1. Lệnh AI cần gọi để tự động đẩy lên:
```bash
# Cách 1: Tự động hoàn toàn (đọc token từ .env hoặc biến môi trường)
python auto_push.py -m "Nội dung cập nhật tính năng"

# Cách 2: Nếu người dùng vừa cung cấp token trực tiếp trong chat
python auto_push.py -m "Nội dung commit" -t "ghp_xxxx_token_here" --save-token

# Cách 3: Dùng PowerShell script trên Windows
powershell -ExecutionPolicy Bypass -File .\auto_push.ps1 -Message "Nội dung commit"
```

### 2.2. Cơ chế hoạt động ngầm của `auto_push.py`:
1. Quét trạng thái kho lưu trữ: nếu có file thay đổi, tự động chạy `git add .` (tự động bỏ qua file nhạy cảm thông qua `.gitignore`).
2. Tạo commit với nội dung chỉ định (hoặc tự sinh timestamp nếu để trống).
3. Lấy URL của `origin` (ví dụ `https://github.com/MagasHoang23/ap_trac_nghiem.git`).
4. Chèn token an toàn dạng: `https://x-access-token:<TOKEN>@github.com/<OWNER>/<REPO>.git`.
5. Đẩy thẳng lên nhánh `main` với `GIT_TERMINAL_PROMPT=0` để đảm bảo **100% không bao giờ bị treo terminal**.

---

## 3. QUY CHUẨN ĐỊNH DẠNG ĐỀ THI & GIẢI THÍCH (RICH TEXT SPECIFICATION)

Ứng dụng `index.html` tích hợp bộ biên dịch `renderRichText(rawText)` và `renderInlineRichText(escapedText)`. Mọi AI khi bổ sung câu hỏi hoặc hướng dẫn người dùng phải tuân thủ đúng cú pháp sau:

| Mục đích | Cú pháp hỗ trợ | Kết quả biên dịch hiển thị |
| :--- | :--- | :--- |
| **In đậm** | `**văn bản**` hoặc `[b]văn bản[/b]` | Chữ in đậm nổi bật (`font-bold text-slate-900`) |
| **In nghiêng** | `*văn bản*` hoặc `[i]văn bản[/i]` | Chữ in nghiêng thanh lịch (`italic`) |
| **Cỡ chữ tiêu đề** | `# Tiêu đề lớn`<br>`## Tiêu đề vừa`<br>`### Tiêu đề nhỏ` | Phân cấp tiêu đề rõ ràng, H1 có vạch kẻ phân cách chân |
| **Cỡ chữ nội tuyến** | `[to]chữ to[/to]`<br>`[rat-to]rất to[/rat-to]`<br>`[nho]chữ nhỏ[/nho]` | Tăng giảm cỡ chữ cho từ ngữ cần nhấn mạnh hoặc ghi chú |
| **Thụt lề dòng** | `2 khoảng trắng` ở đầu dòng (cấp 1)<br>`4 khoảng trắng` (cấp 2)<br>`[tab]nội dung[/tab]` | Thụt lề phân cấp tự động kèm vạch định hướng lề (*indent guide line*) |
| **Gạch đầu dòng** | Bắt đầu bằng `- `, `* `, `+ `, `• ` | Danh sách gạch đầu dòng phân cấp đẹp mắt |
| **Số thứ tự** | Bắt đầu bằng `1. `, `2. `, `a. `, `b. ` | Danh sách đánh số thụt lề chuẩn |
| **Mũi tên suy luận** | Bắt đầu bằng `-> ` hoặc `=> ` hoặc `➜ ` | Mũi tên xanh dẫn chứng: `➔ Kết luận...` |
| **Khối ghi chú** | Bắt đầu dòng bằng `> Ghi chú` | Khối Callout nền xanh, viền xanh thanh lịch |
| **Điểm nhấn màu sắc** | `==đánh dấu==` hoặc `[hl]...[/hl]`<br>`[do]đỏ[/do]`, `[xanh]xanh lá[/xanh]`<br>`[lam]xanh dương[/lam]`, `[cam]cam[/cam]` | Highlight màu vàng mềm mại hoặc chữ có màu sắc phân biệt |
| **Công thức/Code** | `` `công thức / code` `` | Khối Monospace nền xám chữ hồng |
| **Dấu đáp án đúng** | Dấu `*` ngay sau đáp án (VD: `B. 4*`) | Parser tự nhận diện đáp án đúng và loại bỏ dấu `*` khi hiển thị |

---

## 4. PROMPT MẪU CHUẨN ĐỂ YÊU CẦU AI TẠO ĐỀ THI

Trong modal "Thiết lập đề thi", người dùng có sẵn nút **🤖 Sao chép Prompt gửi AI**. Khi bấm nút, hệ thống sẽ tự sao chép đoạn prompt chuẩn sau để người dùng dán vào ChatGPT / Claude / Gemini / DeepSeek:

```text
Bạn là một chuyên gia sư phạm và soạn thảo đề thi trắc nghiệm. Hãy giúp tôi tạo [SỐ LƯỢNG CÂU HỎI, VÍ DỤ: 5 CÂU] trắc nghiệm về chủ đề: [NHẬP CHỦ ĐỀ CỦA BẠN VÀO ĐÂY].

⚠️ YÊU CẦU ĐỊNH DẠNG ĐẶC BIỆT BẮT BUỘC (HỆ THỐNG APP SẼ PARSE TỰ ĐỘNG):
1. TOÀN BỘ KẾT QUẢ XUẤT RA PHẢI ĐƯỢC ĐẶT TRONG DUY NHẤT 1 KHỐI CODE BLOCK (dùng 3 dấu backtick ```text ... ```) ĐỂ GIỮ NGUYÊN KHOẢNG TRẮNG, DẤU CÁCH THỤT LỀ, CÁC KÝ TỰ ĐẶC BIỆT VÀ KHÔNG BỊ TRÌNH DUYỆT TỰ ĐỘNG THAY ĐỔI ĐỊNH DẠNG. Tuyệt đối không viết thêm lời chào hay giải thích nào bên ngoài khối code block này.

2. Cấu trúc mỗi câu hỏi gồm:
   - Dòng tiêu đề câu: Câu 1: [Nội dung câu hỏi] (Có thể viết nhiều dòng, có thể dùng **in đậm**, *in nghiêng*, `code`, [do]chữ đỏ[/do], [xanh]chữ xanh[/xanh]).
   - Các phương án: A., B., C., D. ĐÁP ÁN ĐÚNG PHẢI CÓ DẤU SAO * ĐẶT NGAY PHÍA SAU (Ví dụ: B. Đáp án này đúng*).
   - Phần giải thích: Bắt đầu bằng dòng "Giải thích:".

3. Quy chuẩn trình bày phần GIẢI THÍCH (Phải rõ ràng, gọn gàng, có tính sư phạm cao):
   - Tiêu đề mục: Dùng # Tiêu đề lớn, ## Tiêu đề vừa, ### Tiêu đề nhỏ.
   - Từ khóa cốt lõi: Dùng **in đậm**.
   - Thụt lề phân cấp ý: Dùng 2 khoảng trắng (cấp 1) hoặc 4 khoảng trắng (cấp 2) ở đầu dòng (Hệ thống sẽ tự tạo vạch phân cấp thụt lề).
   - Gạch đầu dòng: Dùng - hoặc * (tự động phân cấp khi có khoảng trắng thụt lề).
   - Mũi tên suy luận: Dùng -> hoặc => để chốt kết luận (Ví dụ: -> Do đó đáp án B đúng).
   - Ghi chú / Trích dẫn nổi bật: Dùng > ở đầu dòng (Ví dụ: > Ghi nhớ: ...).
   - Nổi bật: Dùng ==đánh dấu highlight== hoặc [do]chữ đỏ[/do], [xanh]chữ xanh[/xanh].

MẪU VÍ DỤ CHUẨN CẦN XUẤT RA:
```text
Câu 1: Cho các nhận định sau về **Quang hợp ở thực vật**:
1. Diễn ra chủ yếu ở bào quan lục lạp.
2. Sản phẩm tạo ra gồm Glucose và khí O2.
Hỏi có bao nhiêu nhận định **[do]ĐÚNG[/do]**?
A. 0
B. 1
C. 2*
D. 3

Giải thích:
# Phân tích chi tiết từng nhận định:
- Nhận định 1: **ĐÚNG**. Lục lạp chứa chất diệp lục hấp thụ năng lượng ánh sáng mặt trời.
- Nhận định 2: **ĐÚNG**. Phương trình tổng quát:
  * 6CO2 + 6H2O -> C6H12O6 + 6O2
> ==Kết luận:== Cả 2 nhận định đều chính xác.
-> Do đó, đáp án đúng là **C**.
```

Bây giờ, hãy tạo câu hỏi theo đúng chủ đề trên và xuất ra bên trong 1 khối code block ```text ... ``` duy nhất:
```


---

## 5. BẢO MẬT VÀ BẢO TRÌ

1. **Không bao giờ commit file chứa Token**: File `.gitignore` phải luôn loại trừ `.env`, `.github_token` và `*.token`.
2. **Giữ nguyên các hàm cốt lõi**:
   * `renderRichText`: Bộ biên dịch hiển thị.
   * `parseNewQuizData`: Máy trạng thái phân tích đề bài nhiều dòng.
   * `saveCurrentState` / `loadAttemptForReview`: Bộ nhớ lưu trữ tiến trình và xem lại bài thi.
3. **Kiểm thử trước khi push**:
   * Chạy `node -e "eval(require('fs').readFileSync('index.html','utf8').match(/<script>([\s\S]*?)<\/script>/)[1])"` để xác nhận mã JavaScript không có lỗi cú pháp.
