import os
import re
import sys
from pathlib import Path

from PyQt5.QtCore import Qt
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import (
    QApplication,
    QHBoxLayout,
    QInputDialog,
    QLabel,
    QLineEdit,
    QListWidget,
    QListWidgetItem,
    QMainWindow,
    QMessageBox,
    QPushButton,
    QVBoxLayout,
    QWidget,
)


class BookmarksManager(QMainWindow):
    def __init__(self):
        super().__init__()
        self.xbel_file = Path.home() / ".local" / "share" / "user-places.xbel"
        self.bookmarks = []
        self.init_ui()
        self.load_bookmarks()

    def init_ui(self):
        self.setWindowTitle("Bookmarks Manager")
        self.setGeometry(100, 100, 600, 400)

        # Central widget
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)

        # Title
        title_label = QLabel("Bookmarks Manager")
        title_label.setStyleSheet("font-size: 16px; font-weight: bold; margin: 10px;")
        title_label.setAlignment(Qt.AlignCenter)
        main_layout.addWidget(title_label)

        # File path info
        file_label = QLabel(f"File: {self.xbel_file}")
        file_label.setStyleSheet("color: #666; margin: 5px;")
        main_layout.addWidget(file_label)

        # List widget for bookmarks
        self.list_widget = QListWidget()
        self.list_widget.setAlternatingRowColors(True)
        main_layout.addWidget(self.list_widget, 1)

        # Button layout
        button_layout = QHBoxLayout()

        # Add button
        self.add_btn = QPushButton("Add Bookmark")
        self.add_btn.clicked.connect(self.add_bookmark)
        button_layout.addWidget(self.add_btn)

        # Edit button
        self.edit_btn = QPushButton("Edit Bookmark")
        self.edit_btn.clicked.connect(self.edit_bookmark)
        button_layout.addWidget(self.edit_btn)

        # Remove button
        self.remove_btn = QPushButton("Remove Bookmark")
        self.remove_btn.clicked.connect(self.remove_bookmark)
        button_layout.addWidget(self.remove_btn)

        # Move Up button
        self.move_up_btn = QPushButton("Move Up")
        self.move_up_btn.clicked.connect(self.move_up)
        button_layout.addWidget(self.move_up_btn)

        # Move Down button
        self.move_down_btn = QPushButton("Move Down")
        self.move_down_btn.clicked.connect(self.move_down)
        button_layout.addWidget(self.move_down_btn)

        main_layout.addLayout(button_layout)

        # Save/Cancel buttons
        bottom_layout = QHBoxLayout()

        self.save_btn = QPushButton("Save Changes")
        self.save_btn.clicked.connect(self.save_changes)
        self.save_btn.setStyleSheet(
            "background-color: #4CAF50; color: white; padding: 8px;"
        )
        bottom_layout.addWidget(self.save_btn)

        self.cancel_btn = QPushButton("Cancel")
        self.cancel_btn.clicked.connect(self.close)
        self.cancel_btn.setStyleSheet(
            "background-color: #f44336; color: white; padding: 8px;"
        )
        bottom_layout.addWidget(self.cancel_btn)

        main_layout.addLayout(bottom_layout)

        # Enable/disable buttons based on selection
        self.list_widget.itemSelectionChanged.connect(self.update_buttons_state)
        self.update_buttons_state()

    def load_bookmarks(self):
        """Load bookmarks from the xbel file"""
        try:
            if not self.xbel_file.exists():
                QMessageBox.warning(
                    self, "File Not Found", f"The file {self.xbel_file} does not exist."
                )
                return

            with open(self.xbel_file, "r") as f:
                content = f.read()

            # Extract href values using regex
            pattern = r'href="([^"]*)"'
            self.bookmarks = re.findall(pattern, content)

            # Update list widget
            self.list_widget.clear()
            for bookmark in self.bookmarks:
                self.list_widget.addItem(bookmark)

        except Exception as e:
            QMessageBox.critical(self, "Error", f"Failed to load bookmarks: {str(e)}")

    def add_bookmark(self):
        """Add a new bookmark"""
        url, ok = QInputDialog.getText(
            self, "Add Bookmark", "Enter URL (file:// or http://):"
        )
        if ok and url:
            # Validate URL format
            if not (
                url.startswith("file://")
                or url.startswith("http://")
                or url.startswith("https://")
                or url.startswith("ftp://")
            ):
                QMessageBox.warning(
                    self,
                    "Invalid URL",
                    "URL should start with file://, http://, https://, or ftp://",
                )
                return

            self.bookmarks.append(url)
            self.list_widget.addItem(url)

    def edit_bookmark(self):
        """Edit selected bookmark"""
        selected_items = self.list_widget.selectedItems()
        if not selected_items:
            return

        item = selected_items[0]
        index = self.list_widget.row(item)

        new_url, ok = QInputDialog.getText(
            self, "Edit Bookmark", "Edit URL:", QLineEdit.Normal, item.text()
        )
        if ok and new_url:
            # Validate URL format
            if not (
                new_url.startswith("file://")
                or new_url.startswith("http://")
                or new_url.startswith("https://")
                or new_url.startswith("ftp://")
            ):
                QMessageBox.warning(
                    self,
                    "Invalid URL",
                    "URL should start with file://, http://, https://, or ftp://",
                )
                return

            self.bookmarks[index] = new_url
            item.setText(new_url)

    def remove_bookmark(self):
        """Remove selected bookmark"""
        selected_items = self.list_widget.selectedItems()
        if not selected_items:
            return

        item = selected_items[0]
        index = self.list_widget.row(item)

        reply = QMessageBox.question(
            self,
            "Remove Bookmark",
            f"Remove '{item.text()}'?",
            QMessageBox.Yes | QMessageBox.No,
        )

        if reply == QMessageBox.Yes:
            self.list_widget.takeItem(index)
            del self.bookmarks[index]

    def move_up(self):
        """Move selected bookmark up"""
        current_row = self.list_widget.currentRow()
        if current_row > 0:
            # Swap in bookmarks list
            self.bookmarks[current_row], self.bookmarks[current_row - 1] = (
                self.bookmarks[current_row - 1],
                self.bookmarks[current_row],
            )

            # Swap in list widget
            item = self.list_widget.takeItem(current_row)
            self.list_widget.insertItem(current_row - 1, item)
            self.list_widget.setCurrentRow(current_row - 1)

    def move_down(self):
        """Move selected bookmark down"""
        current_row = self.list_widget.currentRow()
        if current_row < self.list_widget.count() - 1:
            # Swap in bookmarks list
            self.bookmarks[current_row], self.bookmarks[current_row + 1] = (
                self.bookmarks[current_row + 1],
                self.bookmarks[current_row],
            )

            # Swap in list widget
            item = self.list_widget.takeItem(current_row)
            self.list_widget.insertItem(current_row + 1, item)
            self.list_widget.setCurrentRow(current_row + 1)

    def update_buttons_state(self):
        """Enable/disable buttons based on selection"""
        has_selection = len(self.list_widget.selectedItems()) > 0
        self.edit_btn.setEnabled(has_selection)
        self.remove_btn.setEnabled(has_selection)
        self.move_up_btn.setEnabled(has_selection)
        self.move_down_btn.setEnabled(has_selection)

    def save_changes(self):
        """Save bookmarks back to the xbel file"""
        try:
            if not self.xbel_file.exists():
                # Create backup or ask user
                reply = QMessageBox.question(
                    self,
                    "Create File",
                    "File doesn't exist. Create new one?",
                    QMessageBox.Yes | QMessageBox.No,
                )
                if reply != QMessageBox.Yes:
                    return

            # Create backup
            backup_file = self.xbel_file.with_suffix(".xbel.bak")
            if self.xbel_file.exists():
                import shutil

                shutil.copy2(self.xbel_file, backup_file)

            # Read original file content
            with open(self.xbel_file, "r") as f:
                content = f.read()

            # Replace bookmarks in the XML content
            # This is a simplified approach - for production, consider using XML parsing
            lines = content.split("\n")
            new_lines = []
            i = 0

            while i < len(lines):
                line = lines[i]
                if 'href="' in line and i < len(self.bookmarks):
                    # Find the href part and replace it
                    parts = line.split('href="')
                    if len(parts) > 1:
                        new_line = parts[0] + 'href="' + self.bookmarks[0] + '"'
                        for part in parts[2:]:
                            new_line += part
                        new_lines.append(new_line)
                        self.bookmarks = self.bookmarks[1:]
                    else:
                        new_lines.append(line)
                else:
                    new_lines.append(line)
                i += 1

            # Write back to file
            with open(self.xbel_file, "w") as f:
                f.write("\n".join(new_lines))

            QMessageBox.information(
                self,
                "Success",
                f"Bookmarks saved successfully!\nBackup created at: {backup_file}",
            )

            # Reload to ensure consistency
            self.load_bookmarks()

        except Exception as e:
            QMessageBox.critical(self, "Error", f"Failed to save bookmarks: {str(e)}")

    def closeEvent(self, event):
        """Check for unsaved changes before closing"""
        if self.list_widget.count() != len(self.bookmarks):
            reply = QMessageBox.question(
                self,
                "Unsaved Changes",
                "You have unsaved changes. Close anyway?",
                QMessageBox.Yes | QMessageBox.No,
            )
            if reply == QMessageBox.No:
                event.ignore()
                return

        event.accept()


def main():
    app = QApplication(sys.argv)
    app.setStyle("Fusion")  # Modern style

    # Set application icon (optional)
    # app.setWindowIcon(QIcon.fromTheme('bookmarks'))

    window = BookmarksManager()
    window.show()
    sys.exit(app.exec_())


if __name__ == "__main__":
    main()
