//
//  ViewController.swift
//  ToDo_CoreData_L13
//
//  Created by Игорь Мунгалов on 02.11.2022.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    private let cellID = "cell"
    private var tasks = [MyTask]()
    private let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        // Table view cell register
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        setupNavigationBar()
    }
    private func setupNavigationBar() {
        
        // Set title for navigation bar
        title = "Tasks List"
        
        // Title color
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Navigation bar color
        // в примере navigationController?.navigationBar.barTintColor = ...
        navigationController?.navigationBar.backgroundColor = UIColor(
            displayP3Red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
        
    }
    @objc private func addNewTask() {
        showAlert(title: "New Task", message: "What do you want To Do?")
    }
    
    
    
    private func save(_ taskName: String){
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "MyTask", in: managedContext) else { return }
        
        let task = NSManagedObject(entity: entityDescription, insertInto: managedContext) as! MyTask
        task.name = taskName
        
        // сохранить данные
        do {
            try managedContext.save()
            tasks.append(task)
            
            self.tableView.insertRows(at: [IndexPath(row: self.tasks.count - 1, section: 0)], with: .automatic)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func fetchData() {
        //сделать выборку по базе по ключу TestTask (по нашей модели)
        let fetchRequest: NSFetchRequest<MyTask> = MyTask.fetchRequest()
        do {
            tasks = try managedContext.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

// MARK: - UITableViewDataSource
extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController {
    
    // Edit Task
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = tasks[indexPath.row]
        showAlert(title: "Edit Task",
                  message: "Enter new value",
                  currentTask: task) { (newValue) in
            cell.textLabel?.text = newValue
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
    }
    
    // Delete Task
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        if editingStyle == .delete {
            deleteTask(task, indexPath: indexPath)
        }
    }
    
    
    //MARK: - Work with Data Base
    // fetch data, save
    
    // Edit Data:
    private func editTask(_ task: MyTask, newName: String) {
        do {
            task.name = newName
            try managedContext.save()
        } catch let error {
            print("Failed to save", error)
        }
    }
    
    // Delete Data
    private func deleteTask(_ task: MyTask, indexPath: IndexPath) {
        managedContext.delete(task)
        do {
            try managedContext.save()
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error {
            print("Error: \(error)")
        }
    }
}

// MARK: - Setup AlertController
extension ViewController {
    
    private func showAlert(title: String,
                           message: String,
                           currentTask: MyTask? = nil,
                           completion: ((String) -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newValue = alert.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            
            // Edit current task or add new task
            currentTask != nil ? self.editTask(currentTask!, newName: newValue) : self.save(newValue)
            if completion != nil {completion!(newValue)}
        }
        // Cancel Acton
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        // полставляем текущую задачу в текстовое поле при редактировании задачи
        if currentTask != nil {
            alert.textFields?.first?.text = currentTask?.name
        }
        present(alert, animated: true)
    }
}
