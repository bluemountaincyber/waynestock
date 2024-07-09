import React from "react";
import waynestockStage from "../images/waynestock-stage.jpeg";

export default function Home() {
    return (
        <div>
        <div className="imageContainer">
            <img className="darkImage" src={waynestockStage} alt="Waynestock stage" />
            <div class="centeredInImage">
                <p>Welcome to Aurora!</p>
                <p><i>Not just a place, but a state of mind</i></p>
            </div>
        </div>
        <h3 style={{textAlign: "center"}}>Located at the lovely Adlai Stevenson Memorial Park, in Aurora, Illinois</h3>
        <h3 style={{textAlign: "center"}}>Stay tuned for more information!</h3>
        </div>
    );
}