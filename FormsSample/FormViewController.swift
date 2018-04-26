//
//  ViewController.swift
//  FormsSample
//
//  Created by Chris Eidhof on 22.03.18.
//  Copyright © 2018 objc.io. All rights reserved.
//

import UIKit

struct Hotspot {
    var isEnabled: Bool = true
    var password: String = "hello"
}

extension Hotspot {
    var enabledSectionTitle: String? {
        return isEnabled ? "Personal Hotspot Enabled" : nil
    }
}

func hotspotForm(context: RenderingContext<Hotspot>) -> RenderedElement<[Section], Hotspot> {
    var strongReferences: [Any] = []
    var updates: [(Hotspot) -> ()] = []
    
    let renderedToggle = uiSwitch(context: context, keyPath: \Hotspot.isEnabled)
    strongReferences.append(contentsOf: renderedToggle.strongReferences)
    updates.append(renderedToggle.update)
    let toggleCell = FormCell(style: .value1, reuseIdentifier: nil)
    toggleCell.textLabel?.text = "Personal Hotspot"
    toggleCell.contentView.addSubview(renderedToggle.element)
    toggleCell.contentView.addConstraints([
        renderedToggle.element.centerYAnchor.constraint(equalTo: toggleCell.contentView.centerYAnchor),
        renderedToggle.element.trailingAnchor.constraint(equalTo: toggleCell.contentView.layoutMarginsGuide.trailingAnchor)
        ])
    
    
    let passwordCell = FormCell(style: .value1, reuseIdentifier: nil)
    passwordCell.textLabel?.text = "Password"
    passwordCell.accessoryType = .disclosureIndicator
    passwordCell.shouldHighlight = true
    updates.append { state in
        passwordCell.detailTextLabel?.text = state.password
    }

    let renderedPasswordForm = buildPasswordForm(context)
    let nested = FormViewController(sections: renderedPasswordForm.element, title: "Personal Hotspot Password")
    passwordCell.didSelect = {
        context.pushViewController(nested)
    }
    
    let toggleSection = Section(cells: [toggleCell], footerTitle: nil)
    updates.append { state in
        toggleSection.footerTitle = state.enabledSectionTitle
    }

    return RenderedElement(element: [
        toggleSection,
        Section(cells: [
            passwordCell
            ], footerTitle: nil),
    ], strongReferences: strongReferences + renderedPasswordForm.strongReferences) { state in
        renderedPasswordForm.update(state)
        for u in updates {
            u(state)
        }
    }
}

func buildPasswordForm(_ context: RenderingContext<Hotspot>) -> RenderedElement<[Section], Hotspot> {
    let cell = FormCell(style: .value1, reuseIdentifier: nil)
    cell.textLabel?.text = "Password"
    let renderedPasswordField = textField(context: context, keyPath: \.password)
    cell.contentView.addSubview(renderedPasswordField.element)

    let passwordField = renderedPasswordField.element
    cell.contentView.addConstraints([
        passwordField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        passwordField.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
        passwordField.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 20)
    ])

    return RenderedElement(element: [
        Section(cells: [cell], footerTitle: nil)
    ], strongReferences: renderedPasswordField.strongReferences, update: renderedPasswordField.update)
}
