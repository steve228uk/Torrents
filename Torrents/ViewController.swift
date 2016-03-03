//
//  ViewController.swift
//  Torrents
//
//  Created by Stephen Radford on 01/03/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import JLToast

class ViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var objects = Variable([[String:String]]())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObserverToSelectedRow()
        addObserverToSearchBar()
        addObserverToTable()
    }
    
    func addObserverToSelectedRow() {
        tableView.rx_itemSelected.subscribeNext { indexPath in
            UIPasteboard.generalPasteboard().string = self.objects.value[indexPath.row]["link"]
            JLToast.makeText("Link Copied!").show()
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }.addDisposableTo(disposeBag)
    }
    
    func addObserverToTable() {
        objects.asObservable()
        .map { $0.map { $0["title"]! } }
        .bindTo(self.tableView.rx_itemsWithCellIdentifier("Cell")) { row, element, cell in
            cell.textLabel?.text = element
        }.addDisposableTo(disposeBag)
    }
    
    func addObserverToSearchBar() {
        searchBar.rx_text
        .throttle(0.3, scheduler: MainScheduler.instance)
        .subscribeNext { text in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            YIFY.search(text)
                .subscribe(onNext: { self.objects.value = $0 }, onError: { _ in
                    JLToast.makeText("Could not connect to YIFY!").show()
                }, onCompleted: {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }, onDisposed: nil)
                .addDisposableTo(disposeBag)
        }.addDisposableTo(disposeBag)
    }

}

