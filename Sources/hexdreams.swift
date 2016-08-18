// hexdreamsCocoa
// hexdreams.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

public enum Errors : Error {
    case InvalidArgumentError
    case ObjectNotFound(Any,String,String)  // our equivalent of NullPointerException args: sender, function, message
}
