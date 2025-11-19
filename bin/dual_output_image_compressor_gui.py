#!/usr/bin/env python3
"""
Dual-Output Image Compressor - CustomTkinter GUI
Modern, beautiful GUI interface for the image compression tool
"""

import customtkinter as ctk
import tkinter as tk
from tkinter import filedialog, messagebox
import subprocess
import threading
import os
import re
from pathlib import Path

# Configure customtkinter
ctk.set_appearance_mode("dark")  # Modes: "System" (default), "Dark", "Light"
ctk.set_default_color_theme("blue")  # Themes: "blue" (default), "green", "dark-blue"


class ImageCompressorGUI(ctk.CTk):
    def __init__(self):
        super().__init__()

        # Configure window
        self.title("🚀 Dual-Output Image Compressor")
        self.geometry("900x750")

        # Set minimum window size
        self.minsize(800, 700)

        # Variables
        self.input_dir = tk.StringVar(value="")
        self.output_dir = tk.StringVar(value="./dual_compressed")
        self.size_value = tk.StringVar(value="1")
        self.size_unit = tk.StringVar(value="MB")
        self.parallel_jobs = tk.IntVar(value=20)

        # Process tracking
        self.compression_process = None
        self.is_running = False

        # Setup UI
        self.setup_ui()

    def setup_ui(self):
        """Setup the user interface"""

        # Main container with padding
        main_frame = ctk.CTkFrame(self, fg_color="transparent")
        main_frame.pack(fill="both", expand=True, padx=20, pady=20)

        # Header
        self.create_header(main_frame)

        # Configuration section
        config_frame = ctk.CTkFrame(main_frame)
        config_frame.pack(fill="x", pady=(0, 15))

        config_label = ctk.CTkLabel(
            config_frame,
            text="⚙️ Konfiguration",
            font=ctk.CTkFont(size=18, weight="bold")
        )
        config_label.pack(pady=(15, 10), padx=15, anchor="w")

        self.create_config_section(config_frame)

        # Quick presets
        preset_frame = ctk.CTkFrame(main_frame)
        preset_frame.pack(fill="x", pady=(0, 15))

        preset_label = ctk.CTkLabel(
            preset_frame,
            text="⚡ Schnelleinstellungen",
            font=ctk.CTkFont(size=18, weight="bold")
        )
        preset_label.pack(pady=(15, 10), padx=15, anchor="w")

        self.create_preset_section(preset_frame)

        # Action buttons
        self.create_action_buttons(main_frame)

        # Progress section
        progress_frame = ctk.CTkFrame(main_frame)
        progress_frame.pack(fill="both", expand=True, pady=(0, 15))

        progress_label = ctk.CTkLabel(
            progress_frame,
            text="📊 Status",
            font=ctk.CTkFont(size=18, weight="bold")
        )
        progress_label.pack(pady=(15, 10), padx=15, anchor="w")

        self.create_progress_section(progress_frame)

    def create_header(self, parent):
        """Create header section"""
        header_frame = ctk.CTkFrame(parent, fg_color=("#3b8ed0", "#1f538d"))
        header_frame.pack(fill="x", pady=(0, 20))

        title = ctk.CTkLabel(
            header_frame,
            text="🚀 Dual-Output Image Compressor",
            font=ctk.CTkFont(size=24, weight="bold")
        )
        title.pack(pady=15)

        subtitle = ctk.CTkLabel(
            header_frame,
            text="Hochleistungs-Bildkompression für JPEG und PNG",
            font=ctk.CTkFont(size=14)
        )
        subtitle.pack(pady=(0, 15))

    def create_config_section(self, parent):
        """Create configuration input section"""

        # Input directory
        input_frame = ctk.CTkFrame(parent, fg_color="transparent")
        input_frame.pack(fill="x", padx=15, pady=5)

        ctk.CTkLabel(
            input_frame,
            text="📁 Eingabeverzeichnis:",
            font=ctk.CTkFont(size=13, weight="bold")
        ).pack(anchor="w", pady=(5, 2))

        input_row = ctk.CTkFrame(input_frame, fg_color="transparent")
        input_row.pack(fill="x")

        self.input_entry = ctk.CTkEntry(
            input_row,
            textvariable=self.input_dir,
            placeholder_text="Wählen Sie ein Verzeichnis...",
            height=35
        )
        self.input_entry.pack(side="left", fill="x", expand=True, padx=(0, 10))

        ctk.CTkButton(
            input_row,
            text="Durchsuchen",
            command=self.browse_input_dir,
            width=120,
            height=35
        ).pack(side="right")

        # Output directory
        output_frame = ctk.CTkFrame(parent, fg_color="transparent")
        output_frame.pack(fill="x", padx=15, pady=5)

        ctk.CTkLabel(
            output_frame,
            text="💾 Ausgabeverzeichnis:",
            font=ctk.CTkFont(size=13, weight="bold")
        ).pack(anchor="w", pady=(5, 2))

        output_row = ctk.CTkFrame(output_frame, fg_color="transparent")
        output_row.pack(fill="x")

        self.output_entry = ctk.CTkEntry(
            output_row,
            textvariable=self.output_dir,
            height=35
        )
        self.output_entry.pack(side="left", fill="x", expand=True, padx=(0, 10))

        ctk.CTkButton(
            output_row,
            text="Durchsuchen",
            command=self.browse_output_dir,
            width=120,
            height=35
        ).pack(side="right")

        # Target size
        size_frame = ctk.CTkFrame(parent, fg_color="transparent")
        size_frame.pack(fill="x", padx=15, pady=5)

        ctk.CTkLabel(
            size_frame,
            text="📏 Zielgröße:",
            font=ctk.CTkFont(size=13, weight="bold")
        ).pack(anchor="w", pady=(5, 2))

        size_row = ctk.CTkFrame(size_frame, fg_color="transparent")
        size_row.pack(fill="x")

        self.size_entry = ctk.CTkEntry(
            size_row,
            textvariable=self.size_value,
            width=100,
            height=35
        )
        self.size_entry.pack(side="left", padx=(0, 10))

        self.size_unit_menu = ctk.CTkSegmentedButton(
            size_row,
            values=["KB", "MB"],
            variable=self.size_unit,
            height=35
        )
        self.size_unit_menu.pack(side="left")

        # Parallel jobs
        jobs_frame = ctk.CTkFrame(parent, fg_color="transparent")
        jobs_frame.pack(fill="x", padx=15, pady=(5, 15))

        jobs_label_frame = ctk.CTkFrame(jobs_frame, fg_color="transparent")
        jobs_label_frame.pack(fill="x")

        ctk.CTkLabel(
            jobs_label_frame,
            text="⚡ Parallel-Jobs:",
            font=ctk.CTkFont(size=13, weight="bold")
        ).pack(side="left", pady=(5, 2))

        self.jobs_value_label = ctk.CTkLabel(
            jobs_label_frame,
            text=f"{self.parallel_jobs.get()} Jobs",
            font=ctk.CTkFont(size=13, weight="bold"),
            text_color=("#3b8ed0", "#1f538d")
        )
        self.jobs_value_label.pack(side="right", pady=(5, 2))

        self.jobs_slider = ctk.CTkSlider(
            jobs_frame,
            from_=1,
            to=32,
            number_of_steps=31,
            variable=self.parallel_jobs,
            command=self.update_jobs_label,
            height=20
        )
        self.jobs_slider.pack(fill="x", pady=(5, 0))

    def create_preset_section(self, parent):
        """Create quick preset buttons"""
        preset_container = ctk.CTkFrame(parent, fg_color="transparent")
        preset_container.pack(fill="x", padx=15, pady=(0, 15))

        presets = [
            ("🌐 Web", "300", "KB"),
            ("📱 Social Media", "800", "KB"),
            ("📄 Standard", "1", "MB"),
            ("✨ Hohe Qualität", "2", "MB"),
            ("🖨️ Druck", "3", "MB")
        ]

        for i, (name, size, unit) in enumerate(presets):
            btn = ctk.CTkButton(
                preset_container,
                text=name,
                command=lambda s=size, u=unit: self.apply_preset(s, u),
                height=40
            )
            btn.grid(row=0, column=i, padx=5, sticky="ew")
            preset_container.grid_columnconfigure(i, weight=1)

    def create_action_buttons(self, parent):
        """Create start/stop action buttons"""
        action_frame = ctk.CTkFrame(parent, fg_color="transparent")
        action_frame.pack(fill="x", pady=(0, 15))

        self.start_button = ctk.CTkButton(
            action_frame,
            text="🚀 Kompression starten",
            command=self.start_compression,
            height=50,
            font=ctk.CTkFont(size=16, weight="bold"),
            fg_color=("#2fa572", "#106a43")
        )
        self.start_button.pack(side="left", fill="x", expand=True, padx=(0, 10))

        self.stop_button = ctk.CTkButton(
            action_frame,
            text="⏹️ Abbrechen",
            command=self.stop_compression,
            height=50,
            font=ctk.CTkFont(size=16, weight="bold"),
            fg_color=("#d32f2f", "#b71c1c"),
            state="disabled"
        )
        self.stop_button.pack(side="right", fill="x", expand=True)

    def create_progress_section(self, parent):
        """Create progress and log section"""

        # Status label
        self.status_label = ctk.CTkLabel(
            parent,
            text="Bereit zum Starten...",
            font=ctk.CTkFont(size=14),
            text_color=("#3b8ed0", "#1f538d")
        )
        self.status_label.pack(pady=(5, 10), padx=15, anchor="w")

        # Progress bar
        self.progress_bar = ctk.CTkProgressBar(parent, height=25)
        self.progress_bar.pack(fill="x", padx=15, pady=(0, 5))
        self.progress_bar.set(0)

        # Log text area
        log_label = ctk.CTkLabel(
            parent,
            text="📝 Protokoll:",
            font=ctk.CTkFont(size=13, weight="bold")
        )
        log_label.pack(pady=(10, 5), padx=15, anchor="w")

        # Log textbox with scrollbar
        self.log_text = ctk.CTkTextbox(
            parent,
            height=200,
            font=ctk.CTkFont(family="Courier", size=12)
        )
        self.log_text.pack(fill="both", expand=True, padx=15, pady=(0, 15))
        self.log_text.configure(state="disabled")

    # Event handlers
    def browse_input_dir(self):
        """Browse for input directory"""
        directory = filedialog.askdirectory(title="Eingabeverzeichnis wählen")
        if directory:
            self.input_dir.set(directory)
            self.log(f"Eingabeverzeichnis gesetzt: {directory}")

    def browse_output_dir(self):
        """Browse for output directory"""
        directory = filedialog.askdirectory(title="Ausgabeverzeichnis wählen")
        if directory:
            self.output_dir.set(directory)
            self.log(f"Ausgabeverzeichnis gesetzt: {directory}")

    def update_jobs_label(self, value):
        """Update parallel jobs label"""
        jobs = int(value)
        self.jobs_value_label.configure(text=f"{jobs} Jobs")

    def apply_preset(self, size, unit):
        """Apply a quick preset"""
        self.size_value.set(size)
        self.size_unit.set(unit)
        preset_name = {
            ("300", "KB"): "Web",
            ("800", "KB"): "Social Media",
            ("1", "MB"): "Standard",
            ("2", "MB"): "Hohe Qualität",
            ("3", "MB"): "Druck"
        }.get((size, unit), "Unbekannt")
        self.log(f"✓ {preset_name}-Preset aktiviert: {size}{unit}")

    def log(self, message, level="info"):
        """Add message to log"""
        self.log_text.configure(state="normal")

        # Color coding based on level
        tag = level
        if level == "error":
            color = "#f87171"
        elif level == "success":
            color = "#4ade80"
        elif level == "warning":
            color = "#fbbf24"
        else:
            color = "#60a5fa"

        self.log_text.insert("end", f"{message}\n")

        # Auto-scroll to bottom
        self.log_text.see("end")
        self.log_text.configure(state="disabled")

    def start_compression(self):
        """Start the compression process"""

        # Validate inputs
        input_path = self.input_dir.get().strip()
        output_path = self.output_dir.get().strip()

        if not input_path:
            messagebox.showerror("Fehler", "Bitte wählen Sie ein Eingabeverzeichnis!")
            return

        if not output_path:
            messagebox.showerror("Fehler", "Bitte wählen Sie ein Ausgabeverzeichnis!")
            return

        if not os.path.isdir(input_path):
            messagebox.showerror("Fehler", f"Eingabeverzeichnis existiert nicht:\n{input_path}")
            return

        # Get parameters
        size = self.size_value.get()
        unit = "k" if self.size_unit.get() == "KB" else "m"
        size_param = f"-{unit}{size}"
        jobs = self.parallel_jobs.get()

        # Update UI
        self.start_button.configure(state="disabled")
        self.stop_button.configure(state="normal")
        self.progress_bar.set(0)
        self.is_running = True

        # Clear log
        self.log_text.configure(state="normal")
        self.log_text.delete("1.0", "end")
        self.log_text.configure(state="disabled")

        # Log start
        self.log("=" * 60)
        self.log("🚀 Starte Kompression...")
        self.log(f"📁 Eingabe: {input_path}")
        self.log(f"💾 Ausgabe: {output_path}")
        self.log(f"📏 Zielgröße: {size}{unit.upper()}B")
        self.log(f"⚡ Jobs: {jobs}")
        self.log("=" * 60)

        self.status_label.configure(text="🔄 Kompression läuft...")

        # Start compression in thread
        thread = threading.Thread(
            target=self.run_compression,
            args=(input_path, output_path, size_param, jobs),
            daemon=True
        )
        thread.start()

    def run_compression(self, input_path, output_path, size_param, jobs):
        """Run the compression process in background thread"""

        try:
            # Get script path
            script_dir = Path(__file__).parent
            script_path = script_dir / "dual_output_image_compressor.sh"

            if not script_path.exists():
                self.after(0, lambda: self.log(f"✗ Skript nicht gefunden: {script_path}", "error"))
                self.after(0, self.compression_finished)
                return

            # Build command
            cmd = [
                str(script_path),
                input_path,
                output_path,
                size_param
            ]

            # Set environment variable for parallel jobs
            env = os.environ.copy()
            env["DUAL_COMPRESSOR_JOBS"] = str(jobs)

            # Run process
            self.compression_process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
                env=env
            )

            # Read output line by line
            for line in self.compression_process.stdout:
                if not self.is_running:
                    break

                line = line.rstrip()
                if line:
                    # Update progress based on output
                    self.after(0, lambda l=line: self.process_output_line(l))

            # Wait for process to complete
            self.compression_process.wait()

            # Check exit code
            if self.is_running:
                if self.compression_process.returncode == 0:
                    self.after(0, lambda: self.log("=" * 60))
                    self.after(0, lambda: self.log("✓ Kompression erfolgreich abgeschlossen!", "success"))
                    self.after(0, lambda: self.log(f"📁 Ausgabe: {output_path}", "success"))
                    self.after(0, lambda: self.log("=" * 60))
                    self.after(0, lambda: self.status_label.configure(text="✓ Kompression abgeschlossen!"))
                    self.after(0, lambda: self.progress_bar.set(1.0))
                else:
                    self.after(0, lambda: self.log(f"✗ Kompression fehlgeschlagen (Exit Code: {self.compression_process.returncode})", "error"))
                    self.after(0, lambda: self.status_label.configure(text="✗ Fehler bei der Kompression"))

        except Exception as e:
            self.after(0, lambda: self.log(f"✗ Fehler: {str(e)}", "error"))
            self.after(0, lambda: self.status_label.configure(text="✗ Fehler aufgetreten"))

        finally:
            self.after(0, self.compression_finished)

    def process_output_line(self, line):
        """Process output line from compression script"""

        # Check for progress indicators
        if "Komprimiere" in line or "Compressing" in line:
            self.log(line)
            # Update progress bar (approximate)
            current = self.progress_bar.get()
            if current < 0.9:
                self.progress_bar.set(current + 0.05)

        elif "✓" in line or "Fertig" in line or "Done" in line:
            self.log(line, "success")

        elif "✗" in line or "Fehler" in line or "Error" in line:
            self.log(line, "error")

        elif "⚠" in line or "Warnung" in line or "Warning" in line:
            self.log(line, "warning")

        else:
            self.log(line)

    def stop_compression(self):
        """Stop the compression process"""
        if self.compression_process:
            self.log("⚠️ Abbruch angefordert...", "warning")
            self.compression_process.terminate()
            self.is_running = False
            self.status_label.configure(text="⚠️ Kompression abgebrochen")

    def compression_finished(self):
        """Called when compression finishes"""
        self.start_button.configure(state="normal")
        self.stop_button.configure(state="disabled")
        self.is_running = False
        self.compression_process = None


def main():
    """Main entry point"""
    app = ImageCompressorGUI()
    app.mainloop()


if __name__ == "__main__":
    main()
