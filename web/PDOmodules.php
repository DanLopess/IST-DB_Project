<?php
    $user="ist190590";
    $pass="ola12345";
    $loginNfo="pgsql:host=db.ist.utl.pt;dbname=$user";


    function addSimpleCategory($category){
        try{
            $db = startConnection();

            $db->beginTransaction();

            $inCat = $db->prepare("INSERT INTO categoria (nome) VALUES (:nome)");
            $inSCat = $db->prepare("INSERT INTO categoria_simples (nome) VALUES (:nome)");

            $inCat->bindParam(":nome", $category, PDO::PARAM_STR);
            $inSCat->bindParam(":nome", $category, PDO::PARAM_STR);

            $inCat->execute();
            $inSCat->execute();

            $db->commit();

            $db = null;

            echo('<p>Success!</p>');

        }
        catch (PDOException $e) {
            $db->rollback();
            $db = null;
            print("Error: ".$e->getMessage());
            die();
        }
    }

    function addSuperCategory($cat_name, $simple_name){

        try {

            $db = startConnection();

            $db->beginTransaction();

            $inCat = $db->prepare("INSERT INTO categoria (nome) VALUES (?)");
            $inSupCat = $db->prepare("INSERT INTO super_categoria (nome) VALUES (?)");
            $inCon = $db->prepare("INSERT INTO constituida (super_categoria, categoria) VALUES (?, ?)");

            $inCat->bindParam(1, $cat_name, PDO::PARAM_STR);
            $inSupCat->bindParam(1, $cat_name, PDO::PARAM_STR);
            $inCon->bindParam(1, $cat_name, PDO::PARAM_STR);
            $inCon->bindParam(2, $simple_name, PDO::PARAM_STR);


            $inCat->execute();
            $inSupCat->execute();
            $inCon->execute();

            $db->commit();

            $db = null;

            echo('<p>Success!</p>');
        }
        catch (PDOException $e){
            $db->rollback();
            $db = null;
            print("Error: ".$e->getMessage());
            die();
        }
    }

    function removeSuperCategory($cat_name){
        try{
            $db = startConnection();

            $stmt = $db->prepare("SELECT * FROM checkForSuperCategory(?)");
            $stmt->bindParam(1, $cat_name, PDO::PARAM_STR);
            $stmt->execute();
            $stmt->setFetchMode(PDO::FETCH_NUM);
            $res = $stmt->fetch();

            if($res[0] == 't') {
                echo("<p>Can\'t remove category $cat_name : category is a sub category of another category</p>");
                $res = null;
                $db = null;
                die();
            } else {
				$res = null;
				$db->beginTransaction();

				$stmt = $db->prepare("DELETE FROM constituida WHERE super_categoria = ?");
				$stmt->bindParam(1, $cat_name, PDO::PARAM_STR);
				$stmt->execute();

				$stmt = $db->prepare("DELETE FROM super_categoria WHERE nome = ?");
				$stmt->bindParam(1, $cat_name, PDO::PARAM_STR);
				$stmt->execute();

	            $stmt = $db->prepare("DELETE FROM categoria WHERE nome = ?");
	            $stmt->bindParam(1, $cat_name, PDO::PARAM_STR);
	            $stmt->execute();


	            $db->commit();

	            $db = null;

	            echo('<p>Success!</p>');
			}
        }
        catch (PDOException $e){
            $db->rollback();
            $db = null;
            print("Error: ".$e->getMessage());
            die();
        }
    }

    function removeSimpleCategory($cat_name){

        try{
            $db = startConnection();

            $stmt = $db->prepare("SELECT checkForSuperCategory(?)");
            $stmt->bindParam(1, $cat_name, PDO::PARAM_STR);
            $stmt->execute();
            $stmt->setFetchMode(PDO::FETCH_NUM);
            $res = $stmt->fetch();

            if($res[0] == 't') {
                echo("<p>Can\'t remove category $cat_name : category is a sub category of another category</p>");
                $db = null;
				$res = null;
                die();
            } else {
				$res = null;
				$db->beginTransaction();

				$stmt = $db->prepare("DELETE FROM categoria_simples WHERE nome = ?");
				$stmt->bindParam(1, $cat_name, PDO::PARAM_STR);
				$stmt->execute();

				$stmt = $db->prepare("DELETE FROM categoria WHERE nome = ?");
				$stmt->bindParam(1, $cat_name, PDO::PARAM_STR);
				$stmt->execute();


	            $db->commit();

	            $db = null;

	            echo('<p>Success!</p>');
			}
        }
        catch (PDOException $e){
            $db->rollback();
            $db = null;
            print("Error: ".$e->getMessage());
            die();
        }

    }

    function insertProduct($ean, $design, $categoria, $forn_prim, $forn_sec){

        try {
            $db = startConnection();

            $db->beginTransaction();

            $inProd = $db->prepare("INSERT INTO produto VALUES (:ean, :design, :cat, :forn_prim, CURRENT_DATE)");
            $inProd->bindParam(":ean", $ean, PDO::PARAM_INT);
            $inProd->bindParam(":design", $design, PDO::PARAM_STR);
            $inProd->bindParam(":cat", $categoria, PDO::PARAM_STR);
            $inProd->bindParam(":forn_prim", $forn_prim, PDO::PARAM_INT);
            $inProd->execute();

            $inSec = $db->prepare("INSERT INTO fornece_sec VALUES (:nif, :ean)");
            $inSec->bindParam(":nif", $forn_sec, PDO::PARAM_INT);
            $inSec->bindParam(":ean", $ean, PDO::PARAM_INT);
            $inSec->execute();


            $db->commit();

            $db = null;

            echo('<p>Success!</p>');

        }
        catch (PDOException $e) {
            $db->rollback();
            $db = null;
            print("Error: ".$e->getMessage());
            die();
        }
    }

    function removeProduct($nome){
        try{
            $db = startConnection();
			$db->beginTransaction();

            $stmt = $db->prepare("SELECT COUNT(*) FROM produto WHERE design = ?");
            $stmt->bindParam(1, $nome, PDO::PARAM_STR);
            $stmt->execute();
			$stmt->setFetchMode(PDO::FETCH_NUM);
            $verify = $stmt->fetch();
            if($verify[0] == 0){
                echo("No such product: $nome");
				$db = null;
                die();
            } else {
                $stmt = $db->prepare("SELECT ean FROM produto WHERE design = ?");
                $stmt->bindParam(1, $nome, PDO::PARAM_STR);
                $stmt->execute();
                $stmt->setFetchMode(PDO::FETCH_NUM);
                $ean = $stmt->fetch();
            }
            $stmt = $db->prepare("DELETE FROM reposicao r WHERE r.ean = :prod_ean");
            $stmt->bindParam(":prod_ean", $ean[0], PDO::PARAM_INT);
            $stmt->execute();

            $stmt = $db->prepare("DELETE FROM planograma p WHERE p.ean = :prod_ean");
            $stmt->bindParam(":prod_ean", $ean[0], PDO::PARAM_INT);
            $stmt->execute();

            $stmt = $db->prepare("DELETE FROM fornece_sec f WHERE f.ean = :prod_ean");
            $stmt->bindParam(":prod_ean", $ean[0], PDO::PARAM_INT);
            $stmt->execute();

            $stmt = $db->prepare("DELETE FROM produto WHERE ean = :prod_ean");
            $stmt->bindParam(":prod_ean", $ean[0], PDO::PARAM_INT);
            $stmt->execute();

            $db->commit();

            $db = null;

            echo('<p>Success!</p>');
        }
        catch (PDOException $e){
            $db->rollback();
            $db = null;
            print("Error: ".$e->getMessage());
            die();
        }
    }

    function listEvents($product) {

        try {
            $db = startConnection();

            $stmt = $db->prepare("SELECT operador, instante, unidades FROM reposicao NATURAL JOIN produto WHERE design = ?");
            $stmt->bindParam(1, $product, PDO::PARAM_STR);
            $stmt->execute();

            $res = $stmt->fetchAll(PDO::FETCH_OBJ);

            echo('<table>');
            echo('<tr><td>Operador</td><td>Instante</td><td>Unidades</td></tr>');
            foreach($res as $r) {
                echo('<tr>');
                echo("<td>$r->operador</td>");
                echo("<td>$r->instante</td>");
                echo("<td>$r->unidades</td>");
                echo('</tr>');
            }
            echo('</table>');

            $res = null;
            $db = null;
        }
        catch (PDOException $e){
            $db = null;
            print("Error: ".$e->getMessage());
            die();
        }
    }

    function changeProductName($new_name, $old_name){

        try {
            $db = startConnection();

            $stmt = $db->prepare("UPDATE produto SET design = :new_name WHERE design = :old_name");
            $stmt->bindParam(":new_name", $new_name, PDO::PARAM_STR);
            $stmt->bindParam(":old_name", $old_name, PDO::PARAM_STR);

            $stmt->execute();

            $db = null;

            echo('<p>Success!</p>');
        }
        catch (PDOException $e){
            $db = null;
            print("Error: ".$e->getMessage());
            die();
        }
    }

    function listAllCategories($cat_name){

        try {
            $db = startConnection();

            $stmt = $db->prepare("SELECT * FROM listCatRecursive(?)");
            $stmt->bindParam(1, $cat_name, PDO::PARAM_STR);
            $stmt->execute();

            $res = $stmt->fetchAll(PDO::FETCH_OBJ);

            echo("<table>");
            foreach($res as $r) {
                echo("<tr><td>$r->categ</td></tr>");
            }
            echo("</table>");

            $res = null;
            $db = null;

        }
        catch (PDOException $e){
            $db = null;
            print("Error: ".$e->getMessage());
            die();
        }
    }

    function printUpperPage(){
        echo("
        <html>
            <head>
                <title>Database Management</title>
                <link rel='stylesheet' type='text/css' href='style.css'>
                </head>

                <body style='background-color: #a0a0a0'>

                    <nav>
                        <ul>
                                <li><a href='index.html'>Home</a></li>
                                <div class='center'>
                                        Management System (Market)
                                </div>
                        </ul>
                    </nav>
                ");
    }

    function printLowerPage(){
        echo('</body>
        </html> ');
    }

    function startConnection(){
        try{
            global $loginNfo;
            global $user;
            global $pass;

            $db = new PDO($loginNfo, $user, $pass);

            $db->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
            $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

            return $db;
        }
        catch(PDOException $e){
            print("Error: ".$e->getMessage);
            $db = null;
            die();
        }
    }
?>
