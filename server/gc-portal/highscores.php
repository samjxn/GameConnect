<?php
$page['title'] = "Snake Highscores";
?>
<html>
    <head>
        <title>Game Connect</title>
        <?php require "include/head.inc"; ?>
    </head>
    <body>
        <?php require "include/header.inc"; 
        
        require 'include/mysql.inc';
        $query = "SELECT hi.uid, hi.scoreid, hi.gameid, u.name, u.fbpic, hi.score 
                    FROM db309grp16.highscores AS hi
                    INNER JOIN `db309grp16`.`users` AS u ON hi.uid = u.uid
                    WHERE hi.gameid = 1
                    ORDER BY hi.score DESC 
                    LIMIT 100";
        $result = mysql_query($query) or die('Invalid query: ' . mysql_error());
        $i = 1;
        ?>
        <div class="row">
            <?php if($row[$i] = mysql_fetch_assoc($result)) { ?>
            <div class="col-lg-4 col-sm-6 text-center">
                <img class="img-circle img-responsive img-center" src="<?php echo $row[$i]['fbpic']; ?>" alt="" style="width:200px;height:200px;">
                <h3><b>1.&nbsp;</b><?php echo $row[$i]['name']; ?>
                    <small><?php echo $row[$i]['score']; ?> Points</small>
                </h3>
            </div>
            <?php $i++; } if($row[$i] = mysql_fetch_assoc($result)) { ?>
            <div class="col-lg-4 col-sm-6 text-center">
                <img class="img-circle img-responsive img-center" src="<?php echo $row[$i]['fbpic']; ?>" alt="" style="width:200px;height:200px;">
                <h3><b>2.&nbsp;</b><?php echo $row[$i]['name']; ?>
                    <small><?php echo $row[$i]['score']; ?> Points</small>
                </h3>
            </div>
            <?php $i++; } if($row[$i] = mysql_fetch_assoc($result)) { ?>
            <div class="col-lg-4 col-sm-6 text-center">
                <img class="img-circle img-responsive img-center" src="<?php echo $row[$i]['fbpic']; ?>" alt="" style="width:200px;height:200px;">
                <h3><b>3.&nbsp;</b><?php echo $row[$i]['name']; ?>
                    <small><?php echo $row[$i]['score']; ?> Points</small>
                </h3>
            </div>
            <?php $i++; } ?>
        </div>
        <div class="row">
            <table class="table table-striped table-hover highscores-table" style="margin-left:10px">
                <thead>
                    <tr>
                        <th>Rank</th>
                        <th>Name</th>
                        <th>Score</th>
                    </tr>
                </thead>
                <?php
                while ($row[$i] = mysql_fetch_assoc($result)) {
                    ?>
                    <tr>
                        <td><?php echo $i; ?></td>
                        <td><?php echo $row[$i]['name']; ?></td>
                        <td><?php echo $row[$i]['score']; ?></td>
                    </tr>
                    <?php
                    $i++;
                }
                mysql_close();
                ?>
            </table>
        </div>


        <?php require "include/footer.inc"; ?>
    </body>
</html>