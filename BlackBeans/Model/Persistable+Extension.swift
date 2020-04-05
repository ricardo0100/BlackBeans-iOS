//
//  Persistable+Extension.swift
//  BlackBeans
//
//  Created by Ricardo Gehrke on 04/04/20.
//  Copyright © 2020 Ricardo Gehrke Filho. All rights reserved.
//

import Foundation
import CoreData

extension Persistable {
  
  // MARK: Beans
  
  var allBeansSum: Decimal {
    return creditBeansSum - debitBeansSum
  }
  
  var creditBeansSum: Decimal {
    return sumOfBeans(account: nil, isCredit: true)
  }
  
  var debitBeansSum: Decimal {
    return sumOfBeans(account: nil, isCredit: false)
  }
  
  func beansFetchRequest(for requestType: BeansRequestType) -> NSFetchRequest<Bean> {
    let fetch = NSFetchRequest<Bean>(entityName: "Bean")
    fetch.sortDescriptors = [NSSortDescriptor(key: "creationTimestamp", ascending: true)]
    switch requestType {
    case .all:
      break
    case .forAccount(let account):
      fetch.predicate = NSPredicate(format: "%K == %@", #keyPath(Bean.account), account)
    }
    return fetch
  }
  
  func createBean(name: String, value: Decimal, isCredit: Bool, account: Account) throws {
    let bean = Bean(context: context)
    bean.creationTimestamp = Date()
    bean.updateTimestamp = Date()
    bean.name = name
    bean.account = account
    bean.value = NSDecimalNumber(decimal: value)
    bean.isCredit = isCredit
    try context.save()
  }
  
  func deleteBean(bean: Bean?) throws {
    guard let bean = bean else { return }
    context.delete(bean)
    try context.save()
  }
  
  func updateBean(bean: Bean, name: String, value: Decimal, isCredit: Bool, account: Account) throws {
    bean.name = name
    bean.value = NSDecimalNumber(decimal: value)
    bean.updateTimestamp = Date()
    bean.isCredit = isCredit
    bean.account = account
    try context.save()
  }
  
  func creditBeansSum(for requestType: BeansRequestType) -> Decimal {
    switch requestType {
    case .all:
      return sumOfBeans(account: nil, isCredit: true)
    case .forAccount(let account):
      return sumOfBeans(account: account, isCredit: true)
    }
  }
  
  func debitBeansSum(for requestType: BeansRequestType) -> Decimal {
    switch requestType {
    case .all:
      return sumOfBeans(account: nil, isCredit: false)
    case .forAccount(let account):
      return sumOfBeans(account: account, isCredit: false)
    }
  }
  
  // MARK: Accounts
  
  var allAccountsFetchRequest: NSFetchRequest<Account> {
    let fetch = NSFetchRequest<Account>(entityName: "Account")
    fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    return fetch
  }
  
  func createAccount(name: String) throws {
    let account = Account(context: context)
    account.name = name
    try context.save()
  }
  
  func updateAccount(account: Account, name: String) throws {
    account.name = name
    try context.save()
  }
  
  func deleteAccount(account: Account?) throws {
    guard let account = account else { return }
    context.delete(account)
    try context.save()
  }
  
  // MARK: Category
  
  var allCategoryFetchRequest: NSFetchRequest<Category> {
    let fetch = NSFetchRequest<Category>(entityName: "Category")
    fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    return fetch
  }
  
  func createCategory(name: String) throws {
    let category = Category(context: context)
    category.name = name
    try context.save()
  }
  
  // MARK: Private Methods
  
  private func sumOfBeans(account: Account?, isCredit: Bool) -> Decimal {
    let expression = NSExpressionDescription()
    expression.expression = NSExpression(forFunction: "sum:", arguments:[NSExpression(forKeyPath: "value")])
    expression.name = "sum"
    expression.expressionResultType = .decimalAttributeType

    var predicates = [NSPredicate(format: "isCredit == %@", NSNumber(value: isCredit))]
    if let account = account {
      predicates.append(NSPredicate(format: "account == %@", account))
    }
    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bean")
    fetchRequest.predicate = predicate
    fetchRequest.returnsObjectsAsFaults = false
    fetchRequest.propertiesToFetch = [expression]
    fetchRequest.resultType = .dictionaryResultType
    do {
      let res = try context.fetch(fetchRequest).first as? [String: NSDecimalNumber]
      let creditSum = (res?["sum"] ?? 0).decimalValue
      return creditSum
    } catch {
      Log.error(error)
      fatalError()
    }
  }
}