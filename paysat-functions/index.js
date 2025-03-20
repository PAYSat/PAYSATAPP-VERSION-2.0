const functions = require('firebase-functions');
const nodemailer = require('nodemailer');
const cors = require('cors')({ origin: true });
const axios = require('axios');



const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'apppayment27@gmail.com',
    pass: 'oybw boyd rxtc sizo'
  }
});

// Template base para todos los correos
const baseEmailTemplate = (content) => `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }
        .container {
            max-width: 600px;
            margin: 20px auto;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        .header {
            background: linear-gradient(135deg, #FF0000, #cc0000);
            color: white;
            padding: 20px;
            text-align: center;
            border-radius: 8px 8px 0 0;
        }
        .content {
            padding: 30px;
            color: #333333;
        }
        .footer {
            background-color: #f8f9fa;
            padding: 15px;
            text-align: center;
            font-size: 12px;
            color: #666666;
            border-radius: 0 0 8px 8px;
        }
        .detail-box {
            background-color: #f8f9fa;
            padding: 15px;
            margin: 15px 0;
            border-radius: 4px;
            border-left: 4px solid #40E0D0;
        }
        .button {
            background-color: #40E0D0;
            color: white;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 4px;
            display: inline-block;
            margin: 15px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>PAYSAT E CONEXION BANK</h1>
        </div>
        <div class="content">
            ${content}
        </div>
        <div class="footer">
            © ${new Date().getFullYear()} PAYSAT E CONEXION BANK. Todos los derechos reservados.
        </div>
    </div>
</body>
</html>
`;

// Función para enviar notificaciones de pago
exports.enviarCorreoNotificacion = functions.https.onRequest((req, res) => {
    cors(req, res, () => {
        const {
            correoReceptor,
            nombreReceptor,
            apellidoReceptor,
            monto,
            numeroCuentaEmisor,
            nombreEmisor,
            apellidoEmisor,
            numeroCuentaReceptor
        } = req.body;

        const contenido = `
            <h2>¡Hola ${nombreReceptor} ${apellidoReceptor}!</h2>
            <p>Has recibido un nuevo pago en tu cuenta PAYSAT.</p>
            
            <div class="detail-box">
                <h3 style="margin-top: 0;">Detalles de la transacción:</h3>
                <p><strong>Monto recibido:</strong> ${monto}</p>
                <p><strong>De:</strong> ${nombreEmisor} ${apellidoEmisor}</p>
                <p><strong>Cuenta emisor:</strong> ${numeroCuentaEmisor}</p>
                <p><strong>Cuenta receptora:</strong> ${numeroCuentaReceptor}</p>
                <p><strong>Fecha:</strong> ${new Date().toLocaleString()}</p>
            </div>

            <p>Gracias por confiar en PAYSAT para tus transacciones bancarias.</p>
        `;

        const mailOptions = {
            from: '"PAYSAT E CONEXION BANK" <apppayment27@gmail.com>',
            to: correoReceptor,
            subject: '¡Nuevo pago recibido! - PAYSAT',
            html: baseEmailTemplate(contenido)
        };

        transporter.sendMail(mailOptions, (error, info) => {
            if (error) {
                console.error('Error enviando correo:', error);
                res.status(500).send('Error enviando correo');
            } else {
                console.log('Correo enviado:', info.response);
                res.status(200).send('Correo enviado');
            }
        });
    });
});

// Función para enviar código de verificación
exports.Verficacion_Codigo_IniciarSesion = functions.https.onRequest((req, res) => {
    cors(req, res, () => {
        const { correoReceptor, codigoVerificacion } = req.body;

        if (!correoReceptor || !codigoVerificacion) {
            return res.status(400).send("Correo receptor y código de verificación son necesarios");
        }

        const contenido = `
            <h2>Código de Verificación</h2>
            <p>Has solicitado un código de verificación para iniciar sesión en tu cuenta PAYSAT.</p>
            
            <div class="detail-box">
                <h3 style="margin: 0; text-align: center; font-size: 24px;">Tu código es:</h3>
                <p style="text-align: center; font-size: 32px; font-weight: bold; margin: 20px 0;             color: #FF0000;">
                    ${codigoVerificacion}
                </p>
            </div>

            <p><strong>Nota:</strong> Este código es válido por un tiempo limitado. No compartas este código con nadie.</p>
        `;

        const mailOptions = {
            from: '"PAYSAT E CONEXION BANK" <apppayment27@gmail.com>',
            to: correoReceptor,
            subject: 'Código de verificación - PAYSAT',
            html: baseEmailTemplate(contenido)
        };

        transporter.sendMail(mailOptions, (error, info) => {
            if (error) {
                console.error('Error enviando correo:', error);
                res.status(500).send('Error enviando código de verificación');
            } else {
                console.log('Correo de verificación enviado:', info.response);
                res.status(200).send({ message: 'Correo de verificación enviado', code: codigoVerificacion });
            }
        });
    });
});

// Función para enviar notificación de inicio de sesión
exports.sendLoginNotification = functions.https.onRequest((req, res) => {
    cors(req, res, () => {
        const { correoReceptor, fechaHora } = req.body;

        if (!correoReceptor || !fechaHora) {
            return res.status(400).send("Correo receptor y fecha/hora son necesarios");
        }

        const contenido = `
            <h2>Inicio de Sesión Exitoso</h2>
            <p>Se ha detectado un nuevo inicio de sesión en tu cuenta PAYSAT.</p>
            
            <div class="detail-box">
                <h3 style="margin-top: 0;">Detalles del inicio de sesión:</h3>
                <p><strong>Fecha y hora:</strong> ${fechaHora}</p>
                <p><strong>Cuenta:</strong> ${correoReceptor}</p>
            </div>

            <p><strong>¿No reconoces esta actividad?</strong></p>
            <p>Si no fuiste tú quien inició sesión, por favor contacta inmediatamente con nuestro servicio de soporte.</p>
        `;

        const mailOptions = {
            from: '"PAYSAT E CONEXION BANK" <apppayment27@gmail.com>',
            to: correoReceptor,
            subject: 'Inicio de sesión detectado - PAYSAT',
            html: baseEmailTemplate(contenido)
        };

        transporter.sendMail(mailOptions, (error, info) => {
            if (error) {
                console.error('Error enviando correo:', error);
                res.status(500).send('Error enviando correo');
            } else {
                console.log('Correo enviado:', info.response);
                res.status(200).send('Correo enviado');
            }
        });
    });
});
exports.enviarSolicitudDinero = functions.https.onRequest(async (req, res) => {
    cors(req, res, async () => {
        try {
            const {
                emisorNombre,
                emisorApellido,
                receptorCorreo,
                monto,
                razon
            } = req.body;

            if (!emisorNombre || !emisorApellido || !receptorCorreo || !monto || !razon) {
                return res.status(400).send('Faltan datos requeridos');
            }

            // Construir el contenido del correo
            const contenido = `
                <h2>TE ESTAN PIDIENDO DINERO</h2>
                <p><strong>${emisorNombre} ${emisorApellido}</strong> te ha solicitado un pago.</p>
                
                <div class="detail-box">
                    <p><strong>Monto solicitado:</strong> ${monto}</p>
                    <p><strong>Razón:</strong> ${razon}</p>
                </div>

                <p>Entrando a la App de PAYSat puedes gestionar la Solicitud</p>
              
            `;

            const mailOptions = {
                from: '"PAYSAT E CONEXION BANK" <apppayment27@gmail.com>',
                to: receptorCorreo,
                subject: 'Solicitud de dinero - PAYSAT',
                html: baseEmailTemplate(contenido)
            };

            await transporter.sendMail(mailOptions);

            console.log('Correo enviado a:', receptorCorreo);
            res.status(200).send('Solicitud enviada correctamente');
        } catch (error) {
            console.error('Error enviando la solicitud:', error);
            res.status(500).send('Error enviando la solicitud');
        }
    });
});
exports.enviarConfirmacionSolicitud = functions.https.onRequest(async (req, res) => {
    cors(req, res, async () => {
      try {
        const {
          correoReceptor,
          nombreReceptor,
          apellidoReceptor,
          monto,
          nombreEmisor,
          apellidoEmisor
        } = req.body;
  
        if (!correoReceptor || !nombreReceptor || !apellidoReceptor || !monto || !nombreEmisor || !apellidoEmisor) {
          return res.status(400).send('Faltan datos necesarios');
        }
  
        // Contenido del correo con el nuevo formato
        const contenido = `
          <h2>¡Hola ${nombreReceptor} ${apellidoReceptor}!</h2>
          <p>Tu amigo ${nombreEmisor} ${apellidoEmisor} ha aceptado tu solicitud y te ha transferido un monto de \$${monto}.</p>
          <div class="detail-box">
            <h3>Detalles de la transacción:</h3>
            <p><strong>Monto recibido:</strong> \$${monto}</p>
            <p><strong>De:</strong> ${nombreEmisor} ${apellidoEmisor}</p>
            <p><strong>Fecha:</strong> ${new Date().toLocaleString()}</p>
          </div>
          <p>Gracias por utilizar nuestros servicios.</p>
        `;
  
        // Configuración para enviar el correo
        const mailOptions = {
          from: '"PAYSAT E CONEXION BANK" <apppayment27@gmail.com>',
          to: correoReceptor,
          subject: '¡Nuevo pago recibido! - PAYSAT',
          html: baseEmailTemplate(contenido)
        };
  
        // Enviar el correo
        await transporter.sendMail(mailOptions);
        console.log('Correo de confirmación enviado');
        res.status(200).send('Correo enviado correctamente');
      } catch (error) {
        console.error('Error enviando correo:', error);
        res.status(500).send('Error al enviar correo de confirmación');
      }
    });
  });
  