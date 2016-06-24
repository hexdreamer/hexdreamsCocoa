// hexdreamsCocoa
// hexdreams.swift
// Copyright © 2016 Kenny Leung
// This code is PUBLIC DOMAIN

public enum Error : ErrorProtocol {
    case InvalidArgumentError
    case ObjectNotFound(Any,String,String)  // our equivalent of NullPointerException args: sender, function, message
}
