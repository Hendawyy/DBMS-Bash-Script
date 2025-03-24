#!/bin/bash

TABLE_HEADER="<html>
    <head>
        <style>
            body { font-family: Arial, sans-serif; background-color: #171421; margin: 0; padding: 20px; color: #E0E0E0; }
            table { 
                border-collapse: collapse; 
                width: 90%; 
                max-width: 1200px; 
                margin: 20px auto; 
                box-shadow: 0px 4px 8px rgba(0,0,0,0.2); 
                border-radius: 8px; 
                overflow: hidden; 
                background: #252038; 
            }
            th, td { 
                border: 1px solid #444; 
                text-align: left; 
                padding: 12px; 
                color: #E0E0E0; 
            }
            th { 
                background-color: #8A2BE2; 
                color: white; 
                font-size: 16px; 
                text-transform: uppercase; 
            }
            tr:nth-child(even) { background-color: #2E2448; }
            tr:hover { background-color: #3D3163; }
            h2 { color: #BB86FC; }
            h5 { color: #FF5370; }
        </style>
    </head>
    <body>
    <center>
    <h2>TABLE_NAME_PLACEHOLDER's Table</h2>
    <h5><b>PRIMARY_KEY_PLACEHOLDER</b> is the <b>PK</b> for this Table</h5>
    <table>
        <tr>"
