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
1. TOÀN BỘ KẾT QUẢ XUẤT RA PHẢI ĐƯỢC ĐẶT TRONG DUY NHẤT 1 KHỐI CODE BLOCK (dùng 3 dấu backtick ```text ... ```) ĐỂ GIỮ NGUYÊN KHOẢNG TRẮNG, DẤU CÁCH THỤT LỀ, CÁC KÝ TỰ ĐẶC BIỆT. Tuyệt đối không viết thêm lời chào hay giải thích nào bên ngoài khối code block này.

2. CẤM TRÍCH DẪN RÁC: TUYỆT ĐỐI KHÔNG chèn các thẻ trích dẫn tài liệu như [cite: 1], [citation: 1], [source: 1], [1] vào trong đề bài hay phần giải thích.

3. QUY TẮC CHỖ TRỐNG ĐIỀN TỪ: Với các câu hỏi điền từ vào chỗ trống, hãy dùng 4 hoặc 5 dấu gạch dưới (Ví dụ: "Men make _____ house and women make _____ home").

4. QUY TẮC IN ĐẬM VÀ IN NGHIÊNG:
   - Để in đậm: CHỈ DÙNG **từ khóa** (KHÔNG dùng 2 dấu gạch dưới __ để tránh lỗi nuốt chỗ trống điền từ).
   - Để in nghiêng: CHỈ DÙNG *từ khóa*.

5. Cấu trúc mỗi câu hỏi gồm:
   - Dòng tiêu đề câu: Câu 1: [Nội dung câu hỏi] (Có thể viết nhiều dòng, có thể dùng **in đậm**, *in nghiêng*, `code`, [do]chữ đỏ[/do], [xanh]chữ xanh[/xanh]).
   - Các phương án: A., B., C., D. ĐÁP ÁN ĐÚNG PHẢI CÓ DẤU SAO * ĐẶT NGAY PHÍA SAU (Ví dụ: B. Đáp án này đúng*).
   - Phần giải thích: Bắt đầu bằng dòng "Giải thích:".

6. Trình bày phần GIẢI THÍCH (Phải rõ ràng, gọn gàng, có tính sư phạm cao):
   - Tiêu đề mục: Dùng # Tiêu đề lớn, ## Tiêu đề vừa, ### Tiêu đề nhỏ.
   - Từ khóa cốt lõi: Dùng **in đậm**.
   - Thụt lề phân cấp ý: Dùng 2 khoảng trắng (cấp 1) hoặc 4 khoảng trắng (cấp 2) ở đầu dòng.
   - Gạch đầu dòng: Dùng - hoặc * (tự động phân cấp khi có khoảng trắng thụt lề).
   - Mũi tên suy luận: Dùng -> hoặc => để chốt kết luận (Ví dụ: -> Do đó đáp án B đúng).
   - Ghi chú / Trích dẫn nổi bật: Dùng > ở đầu dòng (Ví dụ: > Ghi nhớ: ...).
   - Nổi bật: Dùng ==đánh dấu highlight== hoặc [do]chữ đỏ[/do], [xanh]chữ xanh[/xanh].

MẪU VÍ DỤ CHUẨN CẦN XUẤT RA:
```text
Câu 1: It is generally believed that "Men make _____ house and women make _____ home".
A. a / a*
B. the / the
C. a / the
D. the / an

Giải thích:
# Phân tích ngữ pháp & Thành ngữ:
- Thành ngữ chuẩn tiếng Anh: **"Men make a house and women make a home"** (Đàn ông xây nhà, đàn bà xây tổ ấm).
- Cả **house** và **home** đều là danh từ đếm được số ít mang nghĩa biểu trưng tổng quát:
  * Nên sử dụng mạo từ bất định **a**.
> ==Ghi nhớ:== Cụm *make a house & make a home* là cặp quán ngữ luôn đi cùng nhau.
-> Do đó, đáp án đúng là **A**.
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



---

## 6. ĐỒNG BỘ ĐÁM MÂY GOOGLE DRIVE & MÃ HÓA BẢO MẬT (CLOUD SYNC ARCHITECTURE)

Hệ thống tích hợp giải pháp đồng bộ dữ liệu đa thiết bị không phụ thuộc vào máy chủ trung gian (Serverless Architecture), lưu trữ trực tiếp trên tài khoản Google Drive của người dùng:

### 6.1. Nguyên lý bảo mật đầu cuối (End-to-End Encryption):
1. **Tài khoản & Mật khẩu**:
   - Mỗi tài khoản Google Drive gắn liền với một mật khẩu do người dùng tự đặt khi đăng ký/khởi tạo.
   - Sử dụng chuẩn **W3C Web Cryptography API** (`window.crypto.subtle`):
     - Hàm băm khóa: **PBKDF2** với **100,000 vòng lặp** HMAC-SHA-256 + Salt ngẫu nhiên 16 bytes.
     - Thuật toán mã hóa: **AES-GCM 256-bit** với IV ngẫu nhiên 12 bytes.
     - Chuỗi xác thực Verifier: SHA-256 (`account + password + salt`).
2. **Khôi phục dữ liệu**:
   - Khi đăng nhập trên thiết bị mới, người dùng nhập tài khoản & mật khẩu.
   - Ứng dụng tải file `ap_trac_nghiem_cloud_backup.json` từ Google Drive của họ và tiến hành kiểm tra verifier + giải mã AES-GCM.
   - **Chỉ khi nhập đúng tài khoản và đúng mật khẩu**, dữ liệu mới được giải mã thành công và nạp vào bài thi. Nếu sai mật khẩu, hệ thống báo lỗi và từ chối truy cập.

### 6.2. Phân bổ đồng bộ ngầm thông minh (Background Auto-sync Strategy):
- **Theo hành động của người dùng (Action-driven)**:
  - Chọn đáp án (`selectAnswer`): Gom nhóm và hoãn đồng bộ (*Debounce 8 giây*) để tránh gửi yêu cầu liên tục khi làm bài nhanh.
  - Cắm cờ câu hỏi (`flagQuestionBtn`): Debounce 8 giây.
  - Nộp bài thi (`proceedWithSubmission`): Kích hoạt đẩy dữ liệu lên Google Drive **ngay lập tức** (0 giây).
  - Nạp đề thi mới (`confirmLoadQuizBtn`): Kích hoạt đẩy dữ liệu lên Google Drive **ngay lập tức** (0 giây).
- **Theo chu kỳ thời gian (Heartbeat-driven)**:
  - Mỗi **45 giây**, ứng dụng kiểm tra trạng thái cờ `isDirty`. Nếu có thay đổi chưa lưu, hệ thống tự động đồng bộ ngầm lên Google Drive.
- **Sao lưu ngoại tuyến (Offline Vault)**:
  - Cho phép xuất file `.json` đã mã hóa hoặc file json thông thường về máy và nạp lại bất cứ lúc nào mà không cần kết nối mạng.

---

## 7. CĂN CHỈNH GIAO DIỆN & CHỐNG PHÓNG TO TRÊN ĐIỆN THOẠI (MOBILE UX RULES)

1. **Khắc phục lỗi phóng to bất ngờ trên điện thoại**:
   - Trình duyệt di động (iOS Safari và Android Chrome) tự động phóng to trang web (auto-zoom) khi người dùng chạm vào các ô `<input>` hoặc `<textarea>` có cỡ chữ `< 16px`.
   - **Quy tắc bắt buộc**: Mọi phần tử nhập liệu trên thiết bị di động phải áp dụng:
     ```css
     @media (max-width: 768px) {
         input, textarea, select, .form-input {
             font-size: 16px !important;
         }
     }
     ```
   - Thiết lập thẻ meta viewport đầy đủ: `<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0">`.
   - Các modal cài đặt phải có `max-h-[92vh]`, `overflow-y: auto`, và đệm padding phù hợp màn hình nhỏ.

2. **Thanh công cụ căn chỉnh**:
   - **Nút cỡ chữ**: `A-` (nhỏ 1.05rem), `A` (chuẩn 1.3rem), `A+` (lớn 1.55rem), `A++` (rất lớn 1.85rem).
   - **Nút căn lề**: Chuyển đổi giữa `Căn trái` và `Căn đều 2 bên` (`justify`).
   - **Toggle danh sách trên điện thoại**: Nút `📋 DS` cho phép thu gọn/mở rộng bảng danh sách câu hỏi để tập trung tối đa không gian cho nội dung trắc nghiệm.


### 6.3. Giải pháp kết nối Google Drive không cần Google Cloud Console (Tránh lỗi 401 invalid_client):
- **Nguyên nhân lỗi 401: invalid_client**: Xảy ra khi dùng Google OAuth 2.0 GIS nhưng chưa cấu hình Client ID hợp lệ đã được ủy quyền domain `https://magashoang23.github.io` trên Google Cloud Console.
- **Giải pháp tối ưu (Google Apps Script Web App)**:
  1. Người dùng chỉ cần vào `script.google.com`, bấm *New project*, dán mã Apps Script (có nút bấm sao chép 1-click trong app).
  2. Bấm *Deploy > New deployment > Web app > Execute as: Me > Who has access: Anyone*.
  3. Dán URL Web App vào ứng dụng -> Toàn bộ dữ liệu đề thi, tiến trình và lịch sử sẽ được mã hóa AES-256 rồi gửi thẳng vào Google Drive của người dùng.
  4. Hoàn toàn miễn phí, không bao giờ hết hạn token, và không cần đăng ký tài khoản Google Cloud Developer.


---

## 8. CÚ PHÁP GẠCH CHÂN & CƠ CHẾ ĐỒNG BỘ ĐÁP ÁN KHI XÁO TRỘN

### 8.1. Định dạng Gạch chân (Underline):
Hỗ trợ các cú pháp:
- `<u>từ cần gạch chân</u>`
- `++từ cần gạch chân++`
- `[u]từ cần gạch chân[/u]` hoặc `[gc]từ cần gạch chân[/gc]`
Biên dịch thành `<span class="underline underline-offset-4 decoration-2 decoration-slate-700 font-medium">...</span>` rõ nét, rất thích hợp cho đề thi tiếng Anh (tìm lỗi sai, phát âm, trọng âm, từ đồng nghĩa/trái nghĩa).

### 8.2. Giải quyết triệt để lỗi lệch đáp án khi xáo trộn (Option-Explanation Synchronization):
1. **Nguyên nhân**: AI soạn đề mặc định coi dòng đầu là A, dòng hai là B... và viết câu kết luận như *"Do đó đáp án đúng là A"*. Khi ứng dụng xáo trộn ngẫu nhiên vị trí các lựa chọn, câu A có thể rơi vào nút D, dẫn đến việc nút D đổi màu xanh nhưng lời giải lại ghi A gây hiểu nhầm.
2. **Cơ chế 3 lớp bảo vệ**:
   - **Lớp 1 (Trong Prompt mẫu)**: Yêu cầu AI luôn kèm theo nội dung chữ của đáp án (VD: *"-> Do đó, đáp án đúng là: what marriage is (Đáp án A)"*).
   - **Lớp 2 (Tự động đồng bộ trong App)**: Trình dựng giao diện tự động bắt các mẫu kết luận như *"đáp án đúng là [A-H]"* và tự động cập nhật khớp với chữ cái/số của nút đáp án thực tế trên màn hình (`[D] what marriage is`).
   - **Lớp 3 (Công cụ điều khiển)**:
     * Nút `A/1`: Chuyển đổi linh hoạt giữa kiểu thẻ chữ cái (`A, B, C, D`) và kiểu số thứ tự (`1, 2, 3, 4`).
     * Nút `🔀`: Cho phép Bật / Tắt tính năng xáo trộn đáp án. Khi tắt, các phương án giữ nguyên 100% thứ tự A, B, C, D như đề bài gốc.


---

## 9. CƠ CHẾ ĐỒNG BỘ THỜI GIAN THỰC ĐA THIẾT BỊ (DUAL-ENGINE REAL-TIME SYNC < 100MS)

### 9.1. Bài toán và Thách thức:
- Khi người dùng sử dụng đồng thời 2 thiết bị (ví dụ: đang làm bài trên điện thoại nhưng muốn màn hình laptop phản chiếu ngay lập tức), nếu chỉ dựa vào lưu trữ Google Drive thì độ trễ mạng và giới hạn tần suất request của Google Apps Script (~1-3 giây) sẽ làm giảm trải nghiệm tương tác trực tiếp.
- Người dùng mong muốn: **"Ấn câu nào trên điện thoại là trên máy tính cũng đồng bộ như thế theo thời gian thực luôn ấy nhưng vẫn giữ cơ chế lưu trên Google Drive"**.

### 9.2. Kiến trúc Đồng bộ Kép (Dual-Engine Architecture):
Ứng dụng kết hợp 2 động cơ hoạt động song song mượt mà:

```
[ Thiết bị 1 (Điện thoại) ]                      [ Thiết bị 2 (Máy tính) ]
         |                                                 |
         |=== (Động cơ 1: WebSocket < 100ms) =============>| (Phản xạ tức thì)
         |    - SELECT_ANSWER, TOGGLE_FLAG, RETRY_QUIZ    | - Tô màu câu trả lời
         |    - Kênh riêng tư băm SHA-256(Email + Mật khẩu)| - Bật giải thích
         |    - Mã hóa đầu cuối AES-GCM 256-bit            | - Cập nhật bảng điểm
         |                                                 | - Hiện Live Toast ⚡
         |                                                 |
         v                                                 v
  [ Debounce 1.5s ]                                 [ Nhịp tim 45s ]
         |                                                 |
         +--------> [ Động cơ 2: Google Drive Master ] <---+
                    (Lưu trữ vĩnh viễn, mã hóa AES-256)
```

1. **Động cơ 1 - Live Sync siêu tốc (< 100ms) qua WebSocket Native**:
   - Sử dụng chuẩn WebSocket thuần của trình duyệt (`new WebSocket(...)`) kết nối mạng pub/sub không máy chủ trung gian.
   - **Tạo kênh riêng tư (Zero Leakage)**: Kênh được băm SHA-256 từ sự kết hợp của email người dùng và mật khẩu (`CryptoVault.getChannelTopic()`). Chỉ những thiết bị đăng nhập cùng tài khoản và mật khẩu mới biết và nghe chung một kênh `ap_quiz_<hash>`.
   - **Mã hóa đầu cuối (E2EE)**: Mọi gói tin sự kiện đều được mã hóa bằng AES-GCM 256-bit trước khi truyền.
   - **Các sự kiện thời gian thực**:
     * `SELECT_ANSWER`: Ngay khi ấn đáp án ở điện thoại, máy tính lập tức tô xanh/đỏ, mở ô giải thích chi tiết, cập nhật lưới số câu hỏi và tính điểm. Kèm Toast nổi: *"⚡ Thiết bị khác vừa chọn đáp án Câu X! [Xem]"*.
     * `TOGGLE_FLAG`: Cắm cờ hoặc bỏ cờ tức thời giữa các máy.
     * `RETRY_QUIZ`: Bấm làm lại đề ở máy này thì máy kia cũng đồng loạt khởi động lại lần thi mới.
     * `SUBMIT_QUIZ`: Nộp bài sẽ kích hoạt cập nhật bảng điểm và lịch sử thi sang các máy khác.
     * `NEW_QUIZ_LOADED`: Nạp đề mới ở máy tính sẽ tự động kéo sang điện thoại mà không cần gõ lại.

2. **Động cơ 2 - Lưu trữ vĩnh viễn trên Google Drive (Permanent Master Backup)**:
   - Thời gian chờ ghi ngầm (debounce) được tối ưu rút ngắn xuống **1.5 giây**.
   - Mọi trạng thái làm bài, đề thi mới nạp, và snapshot lịch sử làm bài đều được lưu bền vững trên file `ap_trac_nghiem_cloud_backup.json` trong Google Drive của người dùng.
   - Khi tắt máy hoặc mở thiết bị mới sau thời gian dài ngoại tuyến, ứng dụng sẽ tải snapshot mới nhất từ Google Drive về, sau đó tiếp tục kết nối vào Live Sync WebSocket.


### 9.3. Xử lý trường hợp "Hai máy đang có hai dữ liệu/bộ đề khác nhau":
- **Nguyên nhân**:
  1. Người dùng nạp đề 25 câu trên Điện thoại, nhưng trên Máy tính lại nạp đề 30 câu.
  2. Hai máy chạy hai bộ đề khác nhau thì `questionId` hoàn toàn khác nhau, việc chọn đáp án ở máy này không thể khớp với câu hỏi ở máy kia.
- **Giải pháp 1-Click (Peer-to-Peer Full State Transfer)**:
  1. **Nút `📲 Đồng bộ 2 máy` trên thanh điều hướng**:
     - Cho phép người dùng bấm:
       * `📤 Đẩy bộ đề máy này sang máy kia ngay`: Thiết bị hiện tại sẽ đóng gói toàn bộ danh sách câu hỏi, thứ tự, đáp án đã chọn và URL Google Drive gửi sang máy kia trong < 100ms.
       * `📥 Kéo bộ đề từ máy kia về máy này`: Yêu cầu thiết bị kia truyền đề đang làm về máy này.
  2. **Tự động bắt tay (Auto Peer Handshake)**:
     - Khi một máy mới kết nối kênh, nếu phát hiện số lượng câu hỏi khác nhau (ví dụ 25 câu vs 30 câu), hệ thống sẽ bật thông báo nổi có nút `[Đồng bộ ngay]`.
  3. **Đồng bộ lật câu hỏi song song (Follow Navigation)**:
     - Tùy chọn `🔗 Tự động lật câu hỏi theo máy kia` (mặc định BẬT): Khi chuyển câu trên điện thoại, màn hình máy tính tự động lật sang đúng câu đó để người dùng theo dõi tiện lợi.

  4. **Cơ chế Tự động đối chiếu thời gian & Giải quyết xung đột (Auto Timestamp Reconciliation)**:
     - Khi 2 thiết bị kết nối, chúng tự động gửi gói `SYNC_HANDSHAKE` chứa:
       * `quizFingerprint`: Vân tay nhận diện đề thi.
       * `questionCount`: Số lượng câu hỏi hiện tại.
       * `answeredCount`: Số câu đã trả lời.
       * `lastActiveTimestamp`: Thời điểm thao tác gần nhất được lưu bền vững trên `localStorage`.
     - **Thuật toán tự động**:
       * Nếu 2 máy có đề thi khác nhau (ví dụ: máy tính 30 câu vs điện thoại 25 câu): Thiết bị có `lastActiveTimestamp` mới hơn sẽ tự động đóng gói toàn bộ đề thi bắn sang thiết bị cũ hơn. Thiết bị cũ hơn tự động nhận và tải lại đề trong chưa đầy 100ms mà không cần người dùng thao tác thủ công.
       * Xử lý gói tin đính kèm `> 4KB`: Hỗ trợ tải tự động qua `attachment.url` của máy chủ pub/sub để truyền tải trọn vẹn những bộ đề lớn (từ 30 đến 100+ câu).
       * Watchdog 9s: Ngăn chặn triệt để trạng thái kẹt xoay vòng `Đang đồng bộ...` trên trình duyệt di động.
