var nome = ""
var rgb = [ 0, 0, 0 ]
var org = ""
var cargo = ""
var bank = 0
var mbonline = 0
var mbtotais = 0
var image = ""
var members = {}

$(document).ready(() => {
    $("body").hide()

    window.addEventListener("message",event => {
        switch (event["data"]["action"]) {
            case "openUIlider":
                let data1 = JSON.parse(event["data"]["data"])

                nome = data1[0]
                rgb = data1[1]
                org = data1[2]
                cargo = data1[3]
                bank = data1[4]
                image = data1[5] || "assets/user.jpg"
                members = data1[6]
                mbonline = data1[7]
                mbtotais = data1[8]

                tabletLider()
                $("body").fadeIn(200)
            break

            case "openUIgerente":
                let data2 = JSON.parse(event["data"]["data"])

                nome = data2[0]
                rgb = data2[1]
                org = data2[2]
                cargo = data2[3]
                bank = data2[4]
                image = data2[5] || "assets/user.jpg"
                members = data2[6]
                mbonline = data2[7]
                mbtotais = data2[8]

                tabletGerente()
                $("body").fadeIn(200)
            break

            case "openUImembro":
                let data3 = JSON.parse(event["data"]["data"])

                nome = data3[0]
                rgb = data3[1]
                org = data3[2]
                cargo = data3[3]
                bank = data3[4]
                image = data3[5] || "assets/user.jpg"
                members = data3[6]
                mbonline = data3[7]
                mbtotais = data3[8]

                tabletMembro()
                $("body").fadeIn(200)
            break

            case "closeUI":
                $("body").fadeOut(200)
            break
        }
    })

    document.onkeyup = function(data){
		if (data["which"] == 27){
			$.post("http://yrGroups/closeSystem");
		};
	};
})

function tabletLider() {

    let tablet = document.querySelector("body")

    tablet.innerHTML = `
    <style>
        .pt1 button {
            background-color: rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]});
        }

        .pt1 button:hover {
            background-color: rgb(${rgb[0]-40}, ${rgb[1]-40}, ${rgb[2]-40});
        }

        .card1 {
            background: linear-gradient(45deg, rgb(${rgb[0]-50}, ${rgb[1]-50}, ${rgb[2]-50}), rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]}));  
        }
        .card2 {
            background: linear-gradient(45deg, rgb(${rgb[0]-50}, ${rgb[1]-50}, ${rgb[2]-50}), rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]}));  
        }
        
        .cards p {
            color: rgb(255, 255, 255);
            font-size: 13pt;
            font-weight: 600;
        }
    </style>

    <div class="container" style="border: 4px solid rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]});">
        <div class="pt1">
            <div class="perfil">
                <img src="${image}" style="width: 100px;border-radius: 50px;outline: 4px solid rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]});border: 2px solid var(--bg);">
                <div class="text">
                    <p class="nome">${nome}</p>
                    <p class="org" style="color: rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]})">${org}</p>
                    <p class="cargo">${cargo}</p>
                </div>
            </div>

            <div class="contratar">
                <input type="number" id="id" name="id" placeholder="Passaporte" required>
                <button onclick="contratar()" id="contratar">Contratar</button>
            </div>

            <div class="banco">
                <p id="cofre">Cofre:</p>
                <p style="color: rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]})" class="bank">${bank.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })}</p>
                <br>
                <input type="number" id="bank" name="bank" placeholder="Valor" required>
                <div class="btns">
                    <button onclick="depositar()" id="depositar">Depositar</button>
                    <button onclick="sacar()" id="sacar">Sacar</button>
                </div>
            </div>

            <div class = "cards">
                <div class="card1">
                    <p>Membros Online</p>
                    <h1>${mbonline}</h1>
                </div>
                <div class="card2">
                    <p>Membros Totais</p>
                    <h1>${mbtotais}</h1>
                </div>
            </div>
        </div>
        <div class="pt2">
            <div class="membros">
                <p style="font-weight: 500;padding-left: 20px;font-size: 15pt;margin-bottom: 10px;color: rgb(130, 130, 130);">Membros:</p>
                <div class="member">
                </div>
            </div>
        </div>
    </div>`

    let membroDiv = document.querySelector(".pt2 .membros .member")
    for(var a in members) {
        if (members[a][3]) {
            membroDiv.innerHTML += `<div class="memberUnit" id="${org}">
                <p id="nome">${members[a][0]} #${members[a][1]}</p>
                <div id="carac">
                    <div id="cargo">
                        <p style="color: rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]})">${members[a][2]}</p>
                    </div>
                    <div>
                        <button id="${members[a][1]}" class="btnMemberDemitir btnMember" onclick="btnMemberDemitir(${members[a][1]})"><ion-icon name="close-outline"></ion-icon></button>
                        <button id="${members[a][1]}" class="btnMemberDespromover btnMember" onclick="btnMemberDespromover(${members[a][1]})"><ion-icon name="chevron-down-outline"></ion-icon></button>
                        <button id="${members[a][1]}" class="btnMemberPromover btnMember" onclick="btnMemberPromover(${members[a][1]})"><ion-icon name="chevron-up-outline"></ion-icon></button>
                        <span id="status" style="color: rgb(0, 240, 0);padding-left: 10px;">◉</span>
                    </div>
                </div>
            </div>`
        } else {
            membroDiv.innerHTML += `<div class="memberUnit" id="${org}">
                <p id="nome">${members[a][0]} #${members[a][1]}</p>
                <div id="carac">
                    <div id="cargo">
                        <p style="color: rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]})">${members[a][2]}</p>
                    </div>
                    <div id="states">
                        <button id="${members[a][1]}" class="btnMemberDemitir btnMember" onclick="btnMemberDemitir(${members[a][1]})"><ion-icon name="close-outline"></ion-icon></button>
                        <button id="${members[a][1]}" class="btnMemberDespromover btnMember" onclick="btnMemberDespromover(${members[a][1]})"><ion-icon name="chevron-down-outline"></ion-icon></button>
                        <button id="${members[a][1]}" class="btnMemberPromover btnMember" onclick="btnMemberPromover(${members[a][1]})"><ion-icon name="chevron-up-outline"></ion-icon></button>
                        <span id="status" style="color: rgb(250, 0, 0);padding-left: 10px;">◉</span>
                    </div>
                </div>
            </div>`
        }
    }
}

function contratar() {
    let value = document.getElementById("id").value
    if (!value == "") {
        let data = [ value, org ]
        $.post("http://yrGroups/contratar", JSON.stringify(data));
    }
}

function depositar() {
    let value = document.getElementById("bank").value
    if (!value == "") {
        let data = [ value, org ]
        $.post("http://yrGroups/depositar", JSON.stringify(data));
    }
}

function sacar() {
    let value = document.getElementById("bank").value
    if (!value == "") {
        let data = [ value, org ]
        $.post("http://yrGroups/sacar", JSON.stringify(data));
    }
}

function btnMemberDemitir(id) {
    let data = [ id, org ]
    $.post("http://yrGroups/demitir", JSON.stringify(data));
}
function btnMemberDespromover(id) {
    let data = [ id, org ]
    $.post("http://yrGroups/rebaixar", JSON.stringify(data));
}
function btnMemberPromover(id) {
    let data = [ id, org ]
    $.post("http://yrGroups/promover", JSON.stringify(data));
}

// ------------------------------------------------------------------------

function tabletMembro() {
    let tablet = document.querySelector("body")

    tablet.innerHTML = `
    <style>
        .pt1 button {
            background-color: rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]});
        }

        .pt1 button:hover {
            background-color: rgb(${rgb[0]-40}, ${rgb[1]-40}, ${rgb[2]-40});
        }

        .card1 {
            background: linear-gradient(45deg, rgb(${rgb[0]-50}, ${rgb[1]-50}, ${rgb[2]-50}), rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]}));  
        }
        .card2 {
            background: linear-gradient(45deg, rgb(${rgb[0]-50}, ${rgb[1]-50}, ${rgb[2]-50}), rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]}));  
        }
        
        .cards p {
            color: rgb(255, 255, 255);
            font-size: 13pt;
            font-weight: 600;
        }
    </style>

    <div class="container" style="border: 4px solid rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]});">
        <div class="pt1">
            <div class="perfil">
                <img src="${image}" style="width: 100px;border-radius: 50px;outline: 4px solid rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]});border: 2px solid var(--bg);">
                <div class="text">
                    <p class="nome">${nome}</p>
                    <p class="org" style="color: rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]})">${org}</p>
                    <p class="cargo">${cargo}</p>
                </div>
            </div>

            <div class="banco">
                <p id="cofre">Cofre:</p>
                <p style="color: rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]})" class="bank">${bank.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })}</p>
                <br>
                <input type="number" id="bank" name="bank" placeholder="Valor" required>
                <div class="btns">
                    <button onclick="depositar()" id="depositar">Depositar</button>
                </div>
            </div>

            <div class = "cards">
                <div class="card1">
                    <p>Membros Online</p>
                    <h1>${mbonline}</h1>
                </div>
                <div class="card2">
                    <p>Membros Totais</p>
                    <h1>${mbtotais}</h1>
                </div>
            </div>
        </div>
        <div class="pt2">
            <div class="membros">
                <p style="font-weight: 500;padding-left: 20px;font-size: 15pt;margin-bottom: 10px;color: rgb(130, 130, 130);">Membros:</p>
                <div class="member">
                </div>
            </div>
        </div>
    </div>`

    let membroDiv = document.querySelector(".pt2 .membros .member")
    for(var a in members) {
        if (members[a][3]) {
            membroDiv.innerHTML += `<div class="memberUnit" id="${org}">
                <p id="nome">${members[a][0]} #${members[a][1]}</p>
                <p id="cargo" style="color: rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]})">${members[a][2]}</p>
                <span id="status" style="color: rgb(0, 240, 0);padding-left: 10px;">◉</span>
            </div>`
        } else {
            membroDiv.innerHTML += `<div class="memberUnit" id="${org}">
                <p id="nome">${members[a][0]} #${members[a][1]}</p>
                <p id="cargo" style="color: rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]})">${members[a][2]}</p>
                <span id="status" style="color: rgb(250, 0, 0);padding-left: 10px;">◉</span>
            </div>`
        }
    }
}

function tabletGerente() {

    let tablet = document.querySelector("body")

    tablet.innerHTML = `
    <style>
        .pt1 button {
            background-color: rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]});
        }

        .pt1 button:hover {
            background-color: rgb(${rgb[0]-40}, ${rgb[1]-40}, ${rgb[2]-40});
        }

        .card1 {
            background: linear-gradient(45deg, rgb(${rgb[0]-50}, ${rgb[1]-50}, ${rgb[2]-50}), rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]}));  
        }
        .card2 {
            background: linear-gradient(45deg, rgb(${rgb[0]-50}, ${rgb[1]-50}, ${rgb[2]-50}), rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]}));  
        }
        
        .cards p {
            color: rgb(255, 255, 255);
            font-size: 13pt;
            font-weight: 600;
        }
    </style>

    <div class="container" style="border: 4px solid rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]});">
        <div class="pt1">
            <div class="perfil">
                <img src="${image}" style="width: 100px;border-radius: 50px;outline: 4px solid rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]});border: 2px solid var(--bg);">
                <div class="text">
                    <p class="nome">${nome}</p>
                    <p class="org" style="color: rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]})">${org}</p>
                    <p class="cargo">${cargo}</p>
                </div>
            </div>

            <div class="banco">
                <p id="cofre">Cofre:</p>
                <p style="color: rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]})" class="bank">${bank.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })}</p>
                <br>
                <input type="number" id="bank" name="bank" placeholder="Valor" required>
                <div class="btns">
                    <button onclick="depositar()" id="depositar">Depositar</button>
                    <button onclick="sacar()" id="sacar">Sacar</button>
                </div>
            </div>

            <div class = "cards">
                <div class="card1">
                    <p>Membros Online</p>
                    <h1>${mbonline}</h1>
                </div>
                <div class="card2">
                    <p>Membros Totais</p>
                    <h1>${mbtotais}</h1>
                </div>
            </div>
        </div>
        <div class="pt2">
            <div class="membros">
                <p style="font-weight: 500;padding-left: 20px;font-size: 15pt;margin-bottom: 10px;color: rgb(130, 130, 130);">Membros:</p>
                <div class="member">
                </div>
            </div>
        </div>
    </div>`

    let membroDiv = document.querySelector(".pt2 .membros .member")
    for(var a in members) {
        if (members[a][3]) {
            membroDiv.innerHTML += `<div class="memberUnit" id="${org}">
                <p id="nome">${members[a][0]} #${members[a][1]}</p>
                <p id="cargo" style="color: rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]})">${members[a][2]}</p>
                <span id="status" style="color: rgb(0, 240, 0);padding-left: 10px;">◉</span>
            </div>`
        } else {
            membroDiv.innerHTML += `<div class="memberUnit" id="${org}">
                <p id="nome">${members[a][0]} #${members[a][1]}</p>
                <p id="cargo" style="color: rgb(${rgb[0]}, ${rgb[1]}, ${rgb[2]})">${members[a][2]}</p>
                <span id="status" style="color: rgb(250, 0, 0);padding-left: 10px;">◉</span>
            </div>`
        }
    }
}