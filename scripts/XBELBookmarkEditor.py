#!/usr/bin/env python3
import sys
import xml.etree.ElementTree as ET

from PyQt6.QtCore import Qt
from PyQt6.QtGui import QKeySequence, QShortcut
from PyQt6.QtWidgets import (
    QApplication,
    QFileDialog,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QListWidget,
    QMainWindow,
    QMessageBox,
    QPushButton,
    QVBoxLayout,
    QWidget,
)


class XBELBookmarkEditor(QMainWindow):
    def __init__(self, filename=None):
        super().__init__()
        self.filename = filename
        self.etree = None
        self.root = None
        self.current_item = None

        self.setWindowTitle("XBEL Bookmark Editor")
        self.setGeometry(100, 100, 750, 500)

        # Create main widget and layout
        main_widget = QWidget()
        self.setCentralWidget(main_widget)
        layout = QHBoxLayout(main_widget)

        # Left side - bookmark list
        left_widget = QWidget()
        left_layout = QVBoxLayout(left_widget)
        left_layout.addWidget(QLabel("Bookmarks:"))

        self.bookmark_list = QListWidget()
        self.bookmark_list.itemClicked.connect(self.bookmark_selected)
        left_layout.addWidget(self.bookmark_list)

        # Add buttons below the list
        list_button_layout = QHBoxLayout()
        self.add_btn = QPushButton("Add New")
        self.remove_btn = QPushButton("Remove")
        self.add_btn.clicked.connect(self.add_bookmark)
        self.remove_btn.clicked.connect(self.remove_bookmark)
        list_button_layout.addWidget(self.add_btn)
        list_button_layout.addWidget(self.remove_btn)
        left_layout.addLayout(list_button_layout)

        layout.addWidget(left_widget, 1)

        # Right side - editor panel
        right_widget = QWidget()
        right_layout = QVBoxLayout(right_widget)
        right_layout.addWidget(QLabel("Edit Bookmark:"))

        # Title field
        right_layout.addWidget(QLabel("Title:"))
        self.title_edit = QLineEdit()
        right_layout.addWidget(self.title_edit)

        # Path field
        right_layout.addWidget(QLabel("Path:"))
        self.path_edit = QLineEdit()
        right_layout.addWidget(self.path_edit)

        # Buttons
        button_layout = QHBoxLayout()
        self.update_btn = QPushButton("Update")
        self.update_btn.clicked.connect(self.update_bookmark)
        self.update_btn.setEnabled(False)
        button_layout.addWidget(self.update_btn)

        self.save_btn = QPushButton("Save File")
        self.save_btn.clicked.connect(self.save_file)
        self.save_btn.setEnabled(False)
        button_layout.addWidget(self.save_btn)

        # Keyboard shortcuts
        quit_shortcut = QShortcut(QKeySequence.StandardKey.Quit, self)
        quit_shortcut.activated.connect(self.close)

        save_shortcut = QShortcut(QKeySequence.StandardKey.Save, self)
        save_shortcut.activated.connect(self.save_file)

        right_layout.addLayout(button_layout)
        right_layout.addStretch()

        layout.addWidget(right_widget, 1)

        # Load file if provided
        if filename:
            self.load_file(filename)

    def load_file(self, filename):
        try:
            self.etree = ET.parse(filename)
            self.root = self.etree.getroot()
            self.filename = filename
            self.populate_bookmark_list()
            self.save_btn.setEnabled(True)
            self.setWindowTitle(f"XBEL Bookmark Editor - {filename}")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Failed to load file: {e}")

    def add_bookmark(self):
        """Add a new bookmark"""
        # Create a new bookmark element
        new_bookmark = ET.SubElement(self.root, "bookmark")
        new_bookmark.set("href", "file:///new/path")

        # Add title
        title_elem = ET.SubElement(new_bookmark, "title")
        title_elem.text = "New Bookmark"

        # Add info structure
        info_elem = ET.SubElement(new_bookmark, "info")

        # Add freedesktop metadata
        metadata1 = ET.SubElement(info_elem, "metadata")
        metadata1.set("owner", "http://freedesktop.org")
        icon_elem = ET.SubElement(metadata1, "bookmark:icon")
        icon_elem.set("name", "inode-directory")

        # Add kde metadata
        metadata2 = ET.SubElement(info_elem, "metadata")
        metadata2.set("owner", "http://www.kde.org")
        id_elem = ET.SubElement(metadata2, "ID")

        # Generate a simple ID based on timestamp
        import time

        id_elem.text = f"{int(time.time())}/0"

        # Refresh the list
        self.populate_bookmark_list()

        # Clear selection
        self.current_item = None
        self.title_edit.clear()
        self.path_edit.clear()
        self.update_btn.setEnabled(False)

        QMessageBox.information(self, "Success", "New bookmark added!")

    def remove_bookmark(self):
        """Remove the selected bookmark"""
        # Check if a bookmark is selected
        current_row = self.bookmark_list.currentRow()
        if current_row < 0:
            QMessageBox.warning(self, "Warning", "Please select a bookmark to remove")
            return

        # Confirm deletion
        reply = QMessageBox.question(
            self,
            "Confirm Delete",
            "Are you sure you want to remove this bookmark?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No,
        )

        if reply == QMessageBox.StandardButton.Yes:
            # Find and remove the bookmark
            bookmarks = self.root.findall("bookmark")
            if current_row < len(bookmarks):
                self.root.remove(bookmarks[current_row])

                # Refresh list
                self.populate_bookmark_list()

                # Clear selection
                self.current_item = None
                self.title_edit.clear()
                self.path_edit.clear()
                self.update_btn.setEnabled(False)

                QMessageBox.information(self, "Success", "Bookmark removed!")

    def populate_bookmark_list(self):
        self.bookmark_list.clear()
        for bookmark in self.root.findall("bookmark"):
            title_elem = bookmark.find("title")
            if title_elem is not None and title_elem.text:
                title = title_elem.text
            else:
                title = "Unnamed"
            href = bookmark.get("href", "")

            # Store both title and href as data for later retrieval
            item_text = f"{title} - {href}"
            list_item = self.bookmark_list.addItem(item_text)

    def bookmark_selected(self, item):
        # Find the corresponding bookmark in XML
        selected_text = item.text()
        title_part = selected_text.split(" - ")[0]

        for bookmark in self.root.findall("bookmark"):
            title_elem = bookmark.find("title")
            if title_elem is not None and title_elem.text == title_part:
                self.current_item = bookmark
                self.title_edit.setText(title_elem.text)
                self.path_edit.setText(bookmark.get("href", ""))
                self.update_btn.setEnabled(True)
                break

    def update_bookmark(self):
        if self.current_item is not None:
            # Update title
            title_elem = self.current_item.find("title")
            if title_elem is None:
                title_elem = ET.SubElement(self.current_item, "title")
            title_elem.text = self.title_edit.text()

            # Update href
            self.current_item.set("href", self.path_edit.text())

            # Refresh list
            self.populate_bookmark_list()
            QMessageBox.information(self, "Success", "Bookmark updated!")

    def save_file(self):
        if self.filename:
            try:
                # Register the bookmark namespace
                ET.register_namespace(
                    "bookmark", "http://www.freedesktop.org/standards/desktop-bookmarks"
                )

                # Write with proper XML declaration
                xml_str = ET.tostring(self.root, encoding="unicode", method="xml")
                with open(self.filename, "w", encoding="UTF-8") as f:
                    f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
                    f.write("<!DOCTYPE xbel>\n")
                    f.write(xml_str)

                QMessageBox.information(
                    self, "Success", f"File saved to {self.filename}"
                )
            except Exception as e:
                QMessageBox.critical(self, "Error", f"Failed to save file: {e}")


def main():
    app = QApplication(sys.argv)

    # Get filename from command line or open file dialog
    if len(sys.argv) > 1:
        filename = sys.argv[1]
    else:
        filename, _ = QFileDialog.getOpenFileName(
            None, "Open XBEL File", "", "XBEL Files (*.xbel *.xml);;All Files (*)"
        )
        if not filename:
            sys.exit()

    editor = XBELBookmarkEditor(filename)
    editor.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
