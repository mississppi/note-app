//
//  FocusedValue+NoteList.swift
//  Moore
//
//  Created on 2026-02-21.
//

import SwiftUI

// MARK: - NoteListViewModel FocusedValue
struct NoteListViewModelKey: FocusedValueKey {
    typealias Value = NoteListViewModel
}

extension FocusedValues {
    var noteListViewModel: NoteListViewModelKey.Value? {
        get { self[NoteListViewModelKey.self] }
        set { self[NoteListViewModelKey.self] = newValue }
    }
}
