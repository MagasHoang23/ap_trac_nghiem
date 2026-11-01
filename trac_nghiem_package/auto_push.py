#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
auto_push.py - Cơ chế tự động Commit và Push lên GitHub cho ứng dụng Trắc Nghiệm.
Tác giả: Hỗ trợ tự động hóa cho người dùng và các trợ lý AI.
"""

import os
import sys
# Dam bao ho tro day du ky tu Unicode tren Windows console
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')
import shutil
import subprocess
import argparse
from datetime import datetime

KNOWN_GIT_PATHS = [
    r"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Git\cmd\git.exe",
    r"C:\Program Files\Git\cmd\git.exe",
    r"C:\Program Files\Git\bin\git.exe",
    os.path.expandvars(r"%LOCALAPPDATA%\Programs\Git\cmd\git.exe"),
    os.path.expandvars(r"%ProgramFiles(x86)%\Git\cmd\git.exe")
]

def find_git_executable():
    """Tìm đường dẫn git.exe trên hệ thống."""
    # 1. Thử từ PATH
    git_cmd = shutil.which("git")
    if git_cmd:
        return git_cmd

    # 2. Thử các đường dẫn cài đặt thông dụng trên Windows
    for path in KNOWN_GIT_PATHS:
        if os.path.isfile(path):
            return path

    return "git"

def load_token_from_env_file(project_dir):
    """Đọc GITHUB_TOKEN từ file .env hoặc .github_token nếu có."""
    candidates = [
        os.path.join(project_dir, ".env"),
        os.path.join(project_dir, ".github_token"),
        os.path.join(project_dir, "..", ".env")
    ]
    for filepath in candidates:
        if os.path.isfile(filepath):
            try:
                with open(filepath, "r", encoding="utf-8") as f:
                    for line in f:
                        line = line.strip()
                        if not line or line.startswith("#"):
                            continue
                        if line.startswith("GITHUB_TOKEN=") or line.startswith("GH_TOKEN="):
                            parts = line.split("=", 1)
                            token = parts[1].strip().strip('"').strip("'")
                            if token:
                                return token
                        elif not "=" in line and len(line) >= 20 and not " " in line:
                            # File chỉ chứa raw token
                            return line
            except Exception:
                pass
    return None

def get_remote_info(git_bin, project_dir, remote_name="origin"):
    """Lấy URL của remote git repository."""
    try:
        res = subprocess.run(
            [git_bin, "remote", "get-url", remote_name],
            cwd=project_dir,
            capture_output=True,
            text=True,
            check=True
        )
        return res.stdout.strip()
    except Exception as e:
        return None

def build_authenticated_url(remote_url, token):
    """Xây dựng URL chứa token xác thực để đẩy tự động không cần prompt."""
    if not token or not remote_url:
        return remote_url
    
    # URL dạng https://github.com/owner/repo.git
    if remote_url.startswith("https://"):
        clean_url = remote_url[len("https://"):]
        # Bỏ credentials cũ nếu có dạng username:password@...
        if "@" in clean_url:
            clean_url = clean_url.split("@", 1)[1]
        return f"https://x-access-token:{token}@{clean_url}"
    
    # URL dạng git@github.com:owner/repo.git
    if remote_url.startswith("git@github.com:"):
        path_part = remote_url[len("git@github.com:"):]
        return f"https://x-access-token:{token}@github.com/{path_part}"

    return remote_url

def save_token_to_env(project_dir, token):
    """Lưu token vào file .env cục bộ và thêm vào .gitignore để đảm bảo bảo mật."""
    env_path = os.path.join(project_dir, ".env")
    with open(env_path, "w", encoding="utf-8") as f:
        f.write(f"# File lưu trữ token tự động - KHÔNG commit file này lên GitHub\n")
        f.write(f"GITHUB_TOKEN={token}\n")

    gitignore_path = os.path.join(project_dir, ".gitignore")
    lines = []
    if os.path.isfile(gitignore_path):
        with open(gitignore_path, "r", encoding="utf-8") as f:
            lines = [l.strip() for l in f.readlines()]
    
    dirty = False
    for ign in [".env", ".github_token", "*.token"]:
        if ign not in lines:
            lines.append(ign)
            dirty = True
            
    if dirty:
        with open(gitignore_path, "w", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")

def auto_push(commit_msg=None, token=None, branch="main", remote="origin", project_dir=None, save_token_flag=False):
    """Thực hiện chu trình tự động add, commit và push."""
    if not project_dir:
        project_dir = os.path.abspath(os.path.dirname(__file__))

    git_bin = find_git_executable()
    print(f"🔧 Sử dụng Git: {git_bin}")
    print(f"📁 Thư mục dự án: {project_dir}")

    # 1. Tìm token
    active_token = token
    if not active_token:
        active_token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if not active_token:
        active_token = load_token_from_env_file(project_dir)

    if token and save_token_flag:
        save_token_to_env(project_dir, token)
        print("💾 Đã lưu GITHUB_TOKEN vào .env và cập nhật .gitignore!")

    # 2. Kiểm tra thay đổi cần commit
    status_res = subprocess.run([git_bin, "status", "--porcelain"], cwd=project_dir, capture_output=True, text=True)
    has_changes = bool(status_res.stdout.strip())

    if has_changes:
        print("📦 Phát hiện thay đổi mới. Đang thêm file (git add .)...")
        subprocess.run([git_bin, "add", "."], cwd=project_dir, check=True)

        if not commit_msg:
            now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            commit_msg = f"Cập nhật tự động: {now_str}"

        print(f"✍️ Đang tạo commit: \"{commit_msg}\"...")
        subprocess.run([git_bin, "commit", "-m", commit_msg], cwd=project_dir, check=True)
    else:
        print("ℹ️ Không có thay đổi chưa commit. Chuẩn bị kiểm tra và đẩy các commit hiện có...")

    # 3. Lấy thông tin remote
    remote_url = get_remote_info(git_bin, project_dir, remote)
    if not remote_url:
        print(f"❌ Lỗi: Không tìm thấy remote '{remote}'. Hãy đảm bảo repo đã được gắn remote.")
        return False

    print(f"🌐 Remote URL: {remote_url}")

    # 4. Đẩy lên GitHub
    push_target = remote
    if active_token:
        print("🔑 Đã tìm thấy GitHub Token xác thực tự động.")
        push_target = build_authenticated_url(remote_url, active_token)
    else:
        print("⚠️ Chưa phát hiện GitHub Token. Sẽ thử đẩy thông qua Git Credential mặc định...")

    print(f"🚀 Đang đẩy lên nhánh '{branch}'...")
    env_copy = os.environ.copy()
    env_copy["GIT_TERMINAL_PROMPT"] = "0"
    env_copy["GCM_INTERACTIVE"] = "never"

    try:
        push_res = subprocess.run(
            [git_bin, "push", push_target, branch],
            cwd=project_dir,
            capture_output=True,
            text=True,
            env=env_copy
        )

        if push_res.returncode == 0:
            print("\n" + "="*50)
            print("✅ ĐẨY LÊN GITHUB THÀNH CÔNG RỰC RỠ!")
            print(f"🌿 Nhánh: {branch}")
            print(f"🔗 Repo: {remote_url}")
            print("="*50 + "\n")
            return True
        else:
            err = push_res.stderr.strip()
            print("\n" + "!"*50)
            print(f"❌ Đẩy lên thất bại với mã lỗi {push_res.returncode}:")
            print(err)
            print("!"*50 + "\n")

            if "could not read Username" in err or "Authentication failed" in err or "403" in err:
                print("💡 HƯỚNG DẪN GIẢI QUYẾT CHO NGƯỜI DÙNG & AI:")
                print("1. Tạo một GitHub Personal Access Token (Classic) có quyền 'repo' tại:")
                print("   👉 https://github.com/settings/tokens/new?scopes=repo&description=QuizAppAutoPush")
                print("2. Chạy lệnh sau để lưu token và đẩy tự động vĩnh viễn:")
                print("   python auto_push.py --token <TOKEN_CỦA_BẠN> --save-token")
                print("   (Hoặc tạo file .env trong thư mục với dòng: GITHUB_TOKEN=<TOKEN_CỦA_BẠN>)")
            return False

    except Exception as ex:
        print(f"❌ Ngoại lệ khi thực hiện git push: {ex}")
        return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Tự động Commit & Push lên GitHub.")
    parser.add_argument("-m", "--message", help="Nội dung commit message")
    parser.add_argument("-t", "--token", help="GitHub Personal Access Token (PAT)")
    parser.add_argument("-b", "--branch", default="main", help="Nhánh đẩy lên (mặc định: main)")
    parser.add_argument("-r", "--remote", default="origin", help="Tên remote (mặc định: origin)")
    parser.add_argument("--save-token", action="store_true", help="Lưu token vào file .env cục bộ")

    args = parser.parse_args()
    success = auto_push(
        commit_msg=args.message,
        token=args.token,
        branch=args.branch,
        remote=args.remote,
        save_token_flag=args.save_token
    )
    sys.exit(0 if success else 1)
