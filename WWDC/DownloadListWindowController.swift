//
//  DownloadListWindowController.swift
//  WWDC
//
//  Created by Ruslan Alikhamov on 26/04/15.
//  Copyright (c) 2015 Guilherme Rambo. All rights reserved.
//

import Cocoa

private func ==(lhs: DownloadListItem, rhs: DownloadListItem) -> Bool {
	if lhs === rhs {
		return true
	}
	
	return lhs.url == rhs.url && lhs.task == rhs.task
}

private final class DownloadListItem: Equatable {
	
	let url: String
	let session: Session
	let task: NSURLSessionDownloadTask
	var totalSize: Int?
	var downloadedSize: Int = 0

	var progress: Double {
		if let totalSize = totalSize where totalSize > 0 {
			return Double(downloadedSize) / Double(totalSize)
		} else {
			return 0
		}
	}

	init(url: String, session: Session, task: NSURLSessionDownloadTask) {
		self.url = url
		self.session = session
		self.task = task
	}
}

private let DownloadListCellIdentifier = "DownloadListCellIdentifier"

class DownloadListWindowController: NSWindowController, NSTableViewDelegate, NSTableViewDataSource {
	
	@IBOutlet var tableView: NSTableView!
	
	private var items: [DownloadListItem] = []
	private var downloadStartedHndl: AnyObject?
	private var downloadFinishedHndl: AnyObject?
	private var downloadChangedHndl: AnyObject?
	private var downloadCancelledHndl: AnyObject?
	private var downloadPausedHndl: AnyObject?
	private var downloadResumedHndl: AnyObject?

	private var fileSizeFormatter: NSByteCountFormatter!
	private var percentFormatter: NSNumberFormatter!

	override func windowDidLoad() {
		super.windowDidLoad()
		self.tableView.setDelegate(self)
		self.tableView.setDataSource(self)
		self.tableView.columnAutoresizingStyle = .FirstColumnOnlyAutoresizingStyle

		fileSizeFormatter = NSByteCountFormatter()
		fileSizeFormatter.zeroPadsFractionDigits = true
		fileSizeFormatter.allowsNonnumericFormatting = false

		percentFormatter = NSNumberFormatter()
		percentFormatter.numberStyle = .PercentStyle
		percentFormatter.minimumFractionDigits = 1

		let nc = NSNotificationCenter.defaultCenter()
		self.downloadStartedHndl = nc.addObserverForName(VideoStoreNotificationDownloadStarted, object: nil, queue: NSOperationQueue.mainQueue()) { note in
			if let url = note.object as? String {
				let (item, idx) = self.listItemForURL(url)
				if item != nil {
					return
				}
				let tasks = self.videoStore.allTasks()
				for task in tasks {
					if let _url = task.originalRequest?.URL?.absoluteString where _url == url {
						let sessions = DataStore.SharedStore.cachedSessions!
						let session = sessions.filter { $0.hd_url == url }.first
						let item = DownloadListItem(url: url, session: session!, task: task)
						self.items.append(item)
						self.tableView.insertRowsAtIndexes(NSIndexSet(index: self.items.count), withAnimation: .SlideUp)
					}
				}
			}
		}
		self.downloadFinishedHndl = nc.addObserverForName(VideoStoreNotificationDownloadFinished, object: nil, queue: NSOperationQueue.mainQueue()) { note in
			if let url = note.object as? String {
				let (item, idx) = self.listItemForURL(url)
				if item != nil {
					self.items.remove(item!)
					self.tableView.removeRowsAtIndexes(NSIndexSet(index: idx), withAnimation: .SlideDown)
				}
			}
		}
		self.downloadChangedHndl = nc.addObserverForName(VideoStoreNotificationDownloadProgressChanged, object: nil, queue: NSOperationQueue.mainQueue()) { note in
			if let info = note.userInfo {
				if let url = note.object as? String {
					let (item, idx) = self.listItemForURL(url)
					if let item = item {
						if let expected = info["totalBytesExpectedToWrite"] as? Int,
							let written = info["totalBytesWritten"] as? Int
						{
							item.downloadedSize = written
							item.totalSize = expected
							self.tableView.reloadDataForRowIndexes(NSIndexSet(index: idx), columnIndexes: NSIndexSet(index: 0))
						}
					}
				}
			}
		}
		self.downloadCancelledHndl = nc.addObserverForName(VideoStoreNotificationDownloadCancelled, object: nil, queue: NSOperationQueue.mainQueue()) { note in
			if let object = note.object as? String {
				let (item, idx) = self.listItemForURL(object)
				if item != nil {
					self.items.remove(item!)
					self.tableView.removeRowsAtIndexes(NSIndexSet(index: self.tableView.selectedRow), withAnimation: .EffectGap)
				}
			}
		}
		self.downloadPausedHndl = nc.addObserverForName(VideoStoreNotificationDownloadPaused, object: nil, queue: NSOperationQueue.mainQueue()) { note in
			if let url = note.object as? String {
				let (item, idx) = self.listItemForURL(url)
				if item != nil {
					self.tableView.reloadDataForRowIndexes(NSIndexSet(index: idx), columnIndexes: NSIndexSet(index: 0))
				}
			}
		}
		self.downloadResumedHndl = nc.addObserverForName(VideoStoreNotificationDownloadResumed, object: nil, queue: NSOperationQueue.mainQueue()) { note in
			if let url = note.object as? String {
				let (item, idx) = self.listItemForURL(url)
				if item != nil {
					self.tableView.reloadDataForRowIndexes(NSIndexSet(index: idx), columnIndexes: NSIndexSet(index: 0))
				}
			}
		}
	}
	
	private func listItemForURL(url: String) -> (DownloadListItem?, Int) {
		for (idx, item) in self.items.enumerate() {
			if item.url == url {
				return (item, idx)
			}
		}
		return (nil, NSNotFound)
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self.downloadStartedHndl!)
		NSNotificationCenter.defaultCenter().removeObserver(self.downloadFinishedHndl!)
		NSNotificationCenter.defaultCenter().removeObserver(self.downloadChangedHndl!)
		NSNotificationCenter.defaultCenter().removeObserver(self.downloadCancelledHndl!)
		NSNotificationCenter.defaultCenter().removeObserver(self.downloadPausedHndl!)
		NSNotificationCenter.defaultCenter().removeObserver(self.downloadResumedHndl!)
	}
	
	override func showWindow(sender: AnyObject?) {
		super.showWindow(sender)
		self.items.removeAll(keepCapacity: false)
		let tasks = self.videoStore.allTasks()
		let sessions = DataStore.SharedStore.cachedSessions!
		for task in tasks {
			if let url = task.originalRequest?.URL?.absoluteString {
				let session = sessions.filter { $0.hd_url == url }.first
				let item = DownloadListItem(url: url, session: session!, task: task)
				self.items.append(item)
			}
		}
		self.tableView.reloadData()
	}
	
	var videoStore: VideoStore {
		get {
			return VideoStore.SharedStore()
		}
	}
	
	convenience init() {
		self.init(windowNibName: "DownloadListWindowController")
	}
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return self.items.count
	}
	
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let identifier = tableColumn?.identifier
		let cellView = tableView.makeViewWithIdentifier(identifier!, owner: self) as! DownloadListCellView
		let item = self.items[row]
        
		cellView.textField?.stringValue = "WWDC \(item.session.year) - \(item.session.title)"
        
		if item.progress > 0 {
			if cellView.started == false {
				cellView.startProgress()
			}
			cellView.progressIndicator.doubleValue = item.progress * 100
		}
		cellView.item = item

		cellView.cancelBlock = { [weak self] item, cell in
            let listItem = item as! DownloadListItem
            let task = listItem.task
            switch task.state {
            case .Running:
                self?.videoStore.pauseDownload(listItem.url)
            case .Suspended:
                self?.videoStore.resumeDownload(listItem.url)
            default: break
            }
		};

        var statusText: String?

        switch item.task.state {
		case .Running:
            cellView.progressIndicator.indeterminate = false
            cellView.cancelButton.image = NSImage(named: "NSStopProgressFreestandingTemplate")
            cellView.cancelButton.toolTip = NSLocalizedString("Pause", comment: "pause button tooltip in downloads window")

            statusText = NSLocalizedString("Downloading", comment: "video downloading status in downloads window")
		case .Suspended:
            cellView.progressIndicator.indeterminate = true
            cellView.cancelButton.image = NSImage(named: "NSRefreshFreestandingTemplate")
            cellView.cancelButton.toolTip = NSLocalizedString("Resume", comment: "resume button tooltip in downloads window")

            statusText = NSLocalizedString("Paused", comment: "video paused status in downloads window")
		default: break
		}

        if let statusText = statusText {
            if let totalSize = item.totalSize {
                let downloaded = fileSizeFormatter.stringFromByteCount(Int64(item.downloadedSize))
                let total = fileSizeFormatter.stringFromByteCount(Int64(totalSize))
                let progress = percentFormatter.stringFromNumber(item.progress) ?? "? %"

                cellView.statusLabel.stringValue = "\(statusText) – \(downloaded) / \(total) (\(progress))"
            } else {
                cellView.statusLabel.stringValue = statusText
            }
        }

		return cellView
	}
    
    func delete(sender: AnyObject?) {
        let item = self.items[tableView.selectedRow]
        self.videoStore.cancelDownload(item.url)
    }
	
}
