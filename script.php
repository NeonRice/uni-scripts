#!/usr/bin/env php

<?php
function usage($filename)
{
  echo <<<EOL
  This is a command line PHP script with one option.

    Usage:
      $filename <OPTION>

      <OPTION> can be one of:
        -u specify the username to log processes of. Defaults to all users
        -f specify the file format. Available - csv, html and txt. Defaults to txt
      to print out. With the -h option you can get this help.
  EOL;
}

function format_available($format)
{
  switch (strtolower($format)) {
    case 'csv':
      return true;
    case 'txt':
      return true;
    case 'html':
      return true;
  }
  return false;
}

function tokenize_process($processes, $shortcmd=true)
{
  $c_processes = $processes;
  $header = preg_split('/\s+/', $c_processes[0], -1, PREG_SPLIT_NO_EMPTY);
  foreach ($c_processes as &$process) {
    $process = preg_split('/\s+/', $process, -1, PREG_SPLIT_NO_EMPTY);
    $command_args = array_splice($process, count($header));
    if (!$shortcmd) {
      $process[count($header) - 1] = implode(" ", $command_args);
    }
  }
  return $c_processes;
}

function log_txt($processes, $filename="process_log.txt")
{
  $file = fopen($filename, "w") or die("Unable to open file to write!");
  fwrite($file, implode(PHP_EOL, $processes));
  return $filename;
}

function log_csv($processes, $filename="process_log.csv")
{
  $file = fopen($filename, "w") or die("Unable to open file to write!");
  $processes = tokenize_process($processes);
  foreach ($processes as $process) {
    fputcsv($file, $process);
  }
  return $filename;
}

function get_html_row($elements)
{
  $tr_t = "<tr>%s</tr>";
  $th_t = "<th>%s</th>";
  $tr_content = "";
  foreach ($elements as $element) {
    $tr_content .= sprintf($th_t, $element);
  }
  return sprintf($tr_t, $tr_content);
}

function log_html($processes, $filename="process_log.html")
{
  $file = fopen($filename, "w") or die("Unable to open file to write!");
  $processes = tokenize_process($processes);

  $header = array_splice($processes, 0, 1)[0];
  $table_t = "<table>%s</table>";
  $thead_t = "<thead>%s</thead>";
  $tbody_t = "<tbody>%s</tbody>";

  $thead = sprintf($thead_t, get_html_row($header));
  $body_content = "";
  foreach ($processes as $process) {
    $body_content .= get_html_row($process);
  }

  $tbody = sprintf($tbody_t, $body_content);
  $table = sprintf($table_t, $thead . $tbody);
  fwrite($file, $table);

  return $filename;
}

function create_log($processes, $format)
{
  switch (strtolower($format)) {
    case 'csv':
      return log_csv($processes);
    case 'txt':
      return log_txt($processes);
    case 'html':
      return log_html($processes);
  }
  return '';
}

function main($argc, $argv)
{
  $options = getopt("u:f:");

  if (in_array('-h', $argv)) {
    usage($argv[0]);
    exit(-1);
  }
  $format = $options['f'] ?? 'txt';
  $user = $options['u'] ?? NULL;
  if (!format_available($format)) {
    echo "Format \"$format\" is not available! Available formats: csv, html, txt";
    exit(-1);
  }

  $exec_str = 'ps aux --sort=user';
  if (!is_null($user)) {
    $exec_str = "ps u -u $user";
  }
  $processes = "";
  exec($exec_str, $processes);

  $filename = create_log($processes, $format);
  if ($filename == '') {
    echo "Log creation of format $format failed...\n";
    exit(-1);
  }

  echo "Log: \"$filename\" successfuly created\n";
  echo "Press any key to delete the created log file \"$filename\"...";
  fgets(fopen("php://stdin", "r"));
  if (file_exists($filename)) {
    unlink($filename);
  }
}

main($argc, $argv);
