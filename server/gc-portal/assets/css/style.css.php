<?php 
header('Content-Type: text/css');
/*
 * Copyright 2016 David Boschwitz.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/*
    Created on : Oct 21, 2015, 2:29:12 PM
    Author     : davidboschwitz
*/
?>

/* {
    font-size: 12px;
}*/

html {
}

.mycontent{
    background-color: white;
    padding: 0.5em;
}

#content {
    height: 100%
}

h1 {
    /*font-size: 18px;*/
    font-weight: bold;
    margin-top: 0px;
}

h2 {
    /*font-size: 15px;*/
    font-weight: bold;
}

body {
    //font: 12px/1.5 arial, sans-serif;
    height: 100%;
    width: 100%;
    //background-color: <?php echo $config['background_color'] ?>;
    //padding: 0.5em;
}

/*a {
    color: blue;
}*/

.all-content {
    height: 100%;
    margin: 0px;
    width: 100%;
}

.main-content {
    margin-left: 100px;
    height: 100%;
    float: left;
    //background-color: green
}

.sidebar {
    width: 100px;
    height: 100%;
    float: left;
    background-color: red
}


.header-msg {
    font-size: 26pt;
    font-weight: bold;
}

.page-footer {
    background-color:#f8f6f6;
    border-top: 1px solid rgb(221, 221, 221);
    margin-top: 50px; 
}

.active {
    font-weight: bold;
}

table.award  {
    border-collapse: collapse;
}

table.award td {
    border: 1px solid #666666;
    padding: 0.5em;
}

.awardlabel {
    text-align: right;
    //font-weight: bold;
    background: #f2f2f2;
}

.awardlabelsuccess {
    text-align: center;
    color: green;
    font-weight: bold;
}

.awardlabelfail {
    text-align: center;
    color: red;
    font-weight: bold;
}

.debug {
    border-color: #c63600;
    border-style: solid;
    border-radius: 10px;
    padding: 0.2em;
    width:max-content;
    background-color: lightcoral;
    color: white;
}

.center {
    left: 40%;
    right: 30%;
}

.login-box {
    

}


@media (min-width: 500px) and (max-width: 999px) {
   .login-box {
       width: 55%;
   }
}

@media (min-width: 1000px) {
   .login-box {
       width: 40%;
   }
}

/*-- Tables (taken from iastate.edu) --*/

table.gray, table.cream{
    border-collapse: collapse;
    border-spacing: 0;
    margin-bottom: 12px;
}

table.full-width{
    width: 100%;
}

table.gray th, table.gray td{
    border: 1px solid #bbb;
    border-width: 1px 0;
    padding: 2px 6px;
    text-align: left;
    vertical-align: top;
}

table.gray thead tr th{
    background-color: #e3e3e3;
    border-color: #aaa;
}

table.gray tbody th{
    background-color: #eee;
    border-color: #a7a7a7;
}

table.gray tr.dark-title th{
    background-color: #4a4a4a;
    border-color: #222;
    color: #eee;
}

table.gray tbody tr:nth-child(even) td,
table.gray tbody tr.even td{
    background-color: #f8f8f8;
}

table.gray tbody tr:nth-child(odd) td,
table.gray tbody tr.odd td{
    background-color: #fff;
}

table.gray tbody tr td.ops,
table.cream tbody tr td.ops{
    min-width: 20%;
    white-space: nowrap;
}

table.cream th, table.cream td{
    border: 1px solid #c1b78f;
    border-width: 1px 0;
    padding: 2px 6px;
    text-align: left;
    vertical-align: top;
}

table.cream thead th{
    background-color: #f5e39a;
    border-color: #c63600;
    color: #333;
}

table.cream tbody th{
    background-color: #f3ecd4;
    border-color: #aea581;
}

table.cream tbody td{
    border-color: #c1b78f;
}

table.cream tbody tr:nth-child(even) td,
table.cream tbody tr.even td{
    background: #f8f8f0;
}

table.cream tbody tr:nth-child(odd) td,
table.cream tbody tr.odd td{
    background: #fff;
}

table.cream tbody tr td.ops a + a{
    margin-left: 10px;
}



/* taken from https://github.com/twbs/bootstrap/issues/9588 */
.inverse-dropdown{
  background-color: #222;
  border-color: #080808;
  color: #9d9d9d;
  &>li>a{
    color: #9d9d9d;
    &:hover{
      color: #fff;
      background-color: #000;
    }
  }
  &>.divider {
    background-color: #000;
  }
}
