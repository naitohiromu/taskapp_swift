//
//  ViewController.swift
//  taskapp
//
//  Created by naito.hiromu on 2023/05/30.
//

import UIKit
import RealmSwift   // ←追加

class ViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var searchBar: UISearchBar!
    // Realmインスタンスを取得する
    let realm = try! Realm()  // ←追加
    
    var chats:[String] = []
    
    var searchResults = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)  // ←追加
    var isSearching = false
    //var items = []
    //var currentItems = [String]()
    
    // DB内のタスクが格納されるリスト。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)  // ←追加
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
    /*
    func searchBar(_ searchBar: UISearchBar,selectedScopeButtonIndexDidChange selectedScope: Int){
        if searchBar.text == "" {
            isSearching = false
            tableView.reloadData()
            print(isSearching)
        } else {
            searchResults = realm.objects(Task.self).where({$0.category == "category1"})
            isSearching = true
            tableView.reloadData()
            print(isSearching)
        }
        
    }
    */
    //  検索バーに入力があったら呼ばれる
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text == "" {
            isSearching = false
            tableView.reloadData()
            print(isSearching)
        } else {
            searchResults = realm.objects(Task.self).where({$0.category == searchBar.text!})
            isSearching = true
            tableView.reloadData()
            print(isSearching)
        }
        //tableView.reloadData()
        
    }
     
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching == true{
            return searchResults.count
        }else{
            return taskArray.count  // ←修正する
        }
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if isSearching{
            // Cellに値を設定する  --- ここから ---
            let task = searchResults[indexPath.row]
            cell.textLabel?.text = task.title

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let dateString:String = formatter.string(from: task.date)
            cell.detailTextLabel?.text = dateString
        }else{
            // Cellに値を設定する  --- ここから ---
            let task = taskArray[indexPath.row]
            cell.textLabel?.text = task.title

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let dateString:String = formatter.string(from: task.date)
            cell.detailTextLabel?.text = dateString
        }
        /*
        // Cellに値を設定する  --- ここから ---
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        */
        
        // --- ここまで追加 ---
        
        return cell
    }

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil) //←追加する
    }

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // --- ここから ---
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]

            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id.stringValue)])

            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        } // --- ここまで変更 ---
    }
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController

        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            inputViewController.task = Task()
        }
    }
}
