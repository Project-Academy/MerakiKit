//
//  Request.swift
//  MerakiKit
//
//  Meraki's request type is just `DefaultRequest<Meraki>` from
//  Tapioca, exposed under the familiar `Meraki.Request` / `Request`
//  spelling so no consumer of MerakiKit has to change a callsite.
//  No Meraki-specific modifiers — all request configuration goes
//  through Tapioca's standard fluent surface.
//

import Foundation
import Tapioca

public typealias Request = DefaultRequest<Meraki>
