//
//  SettingsViewController.swift
//  Drrrible
//
//  Created by Suyeol Jeon on 10/03/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import SafariServices
import UIKit

import Carte
import ReactorKit
import ReusableKit
import RxDataSources

final class SettingsViewController: BaseViewController, View {

  // MARK: Constants

  fileprivate struct Reusable {
    static let cell = ReusableCell<SettingItemCell>()
  }


  // MARK: Properties

  fileprivate let dataSource = RxTableViewSectionedReloadDataSource<SettingsViewSection>()


  // MARK: UI

  fileprivate let tableView = UITableView(frame: .zero, style: .grouped).then {
    $0.register(Reusable.cell)
  }


  // MARK: Initializing

  init(reactor: SettingsViewReactor) {
    defer { self.reactor = reactor }
    super.init()
    self.title = "settings".localized
    self.tabBarItem.image = UIImage(named: "tab-settings")
    self.tabBarItem.selectedImage = UIImage(named: "tab-settings-selected")
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(self.tableView)
  }

  override func setupConstraints() {
    self.tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }


  // MARK: Configuring

  func bind(reactor: SettingsViewReactor) {
    self.dataSource.configureCell = { dataSource, tableView, indexPath, sectionItem in
      let cell = tableView.dequeue(Reusable.cell, for: indexPath)
      switch sectionItem {
      case .version(let reactor):
        cell.reactor = reactor

      case .github(let reactor):
        cell.reactor = reactor

      case .icons(let reactor):
        cell.reactor = reactor

      case .openSource(let reactor):
        cell.reactor = reactor

      case .logout(let reactor):
        cell.reactor = reactor
      }
      return cell
    }

    // State
    reactor.state.map { $0.sections }
      .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.isLoggedOut }
      .distinctUntilChanged()
      .filter { $0 }
      .do(onNext: { _ in analytics.log(event: .logout) })
      .subscribe(onNext: { _ in
        // TODO:
        // AppDelegate.shared.presentLoginScreen()
      })
      .disposed(by: self.disposeBag)

    // View
    self.rx.viewDidAppear
      .subscribe(onNext: { _ in analytics.log(event: .viewSettingList) })
      .disposed(by: self.disposeBag)

    self.tableView.rx.itemSelected(dataSource: self.dataSource)
      .subscribe(onNext: { [weak self] sectionItem in
        guard let `self` = self, let reactor = self.reactor else { return }
        switch sectionItem {
        case .version:
          let reactor = VersionViewReactor()
          let viewController = VersionViewController(reactor: reactor)
          self.navigationController?.pushViewController(viewController, animated: true)

        case .github:
          let url = URL(string: "https://github.com/devxoul/Drrrible")!
          let viewController = SFSafariViewController(url: url)
          self.present(viewController, animated: true, completion: nil)

        case .icons:
          let url = URL(string: "https://icons8.com")!
          let viewController = SFSafariViewController(url: url)
          self.present(viewController, animated: true, completion: nil)

        case .openSource:
          let viewController = CarteViewController()
          self.navigationController?.pushViewController(viewController, animated: true)

        case .logout:
          analytics.log(event: .tryLogout)
          let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
          let logoutAction = UIAlertAction(title: "logout".localized, style: .destructive) { _ in
            reactor.action.onNext(.logout)
          }
          let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
          [logoutAction, cancelAction].forEach(actionSheet.addAction)
          self.present(actionSheet, animated: true, completion: nil)
        }
      })
      .disposed(by: self.disposeBag)

    self.tableView.rx.itemSelected
      .subscribe(onNext: { [weak tableView] indexPath in
        tableView?.deselectRow(at: indexPath, animated: false)
      })
      .disposed(by: self.disposeBag)
  }

}
