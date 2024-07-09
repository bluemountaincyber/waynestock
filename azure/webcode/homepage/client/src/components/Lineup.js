import React from "react";
import {
    Grid,
    GridColumn,
    GridRow,
    Image
} from "semantic-ui-react";
import aerosmith from "../images/aerosmith.jpeg";
import vanhalen from "../images/vanhalen.jpeg";
import pearljam from "../images/pearljam.jpeg";
import crucialtaunt from "../images/crucialtaunt.jpeg";

export default function Lineup() {
    const bandNameStyle = {
        position: 'absolute',
        bottom: 10,
        right: -20,
        width: '100%',
        height: 'auto',
        fontSize: '2em',
        color: 'white'
    }
    return (
        <div>
            <h1>Lineup</h1>
                <Grid middle align>
                    <GridRow centered columns={2}>
                        <GridColumn width={11}>
                            <Image fluid src={aerosmith}/>
                            <div style={bandNameStyle}>AEROSMITH</div>
                        </GridColumn>
                        <GridColumn verticalAlign="middle" textAlign="center" width={5}>
                        </GridColumn>
                    </GridRow>
                    <GridRow centered columns={2}>
                        <GridColumn verticalAlign="middle" textAlign="center" width={5}>
                        </GridColumn>
                        <GridColumn width={11}>
                            <Image fluid src={vanhalen}/>
                            <div style={bandNameStyle}>VAN HALEN</div>
                        </GridColumn>
                    </GridRow>
                    <GridRow centered columns={2}>
                        <GridColumn width={11}>
                            <Image fluid src={pearljam}/>
                            <div style={bandNameStyle}>PEARL JAM</div>
                        </GridColumn>
                        <GridColumn verticalAlign="middle" textAlign="center" width={5}>
                        </GridColumn>
                    </GridRow>
                    <GridRow centered columns={2}>
                        <GridColumn verticalAlign="middle" textAlign="center" width={5}>
                        </GridColumn>
                        <GridColumn width={11}>
                            <Image fluid src={crucialtaunt}/>
                            <div style={bandNameStyle}>CRUCIAL TAUNT</div>
                        </GridColumn>
                    </GridRow>
                </Grid>
        </div>
    );
}