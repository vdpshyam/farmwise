
# FarmWise B2B E-commerce Mobile App

FarmWise is a B2B E-commerce Mobile App is built using Flutter for the frontend and Node.js for the backend. This application is designed to facilitate business-to-business transactions specifically for agricultural products. It is built using Flutter for the frontend and Node.js for the backend.

## Features

- **User Authentication :** Secure login and registration for both buyers and sellers.
- **Product Listings :** Browse and search for a wide range of agricultural products.
- **Product Details :** View detailed information about products, including images, descriptions, pricing, and availability.
- **Order Placement :** Easily place orders for desired products with a few simple taps.
- **User Profile :** Manage user profiles, including personal information, order history, and preferences.
- **User Dashboard :** Comprehensive dashboard for users to check summary about their orders, sales, etc.
## Tech Stack

**Client:** Flutter \
**Server:** NodeJS \
**Database:** MongoDB



## Installation

To run the Sales forecasting Website locally on your machine, follow these steps:

#### Prerequisites : 
- Flutter v3
- Node.js v14
- MongoDB

#### Steps : 

1. Clone the repository:

```bash
git clone https://github.com/vdpshyam/farmwise.git
```

2. Navigate to the frontend directory:

```bash
cd farmwise/farm_wise_frontend
```

3. Install the dependencies:

```bash
flutter pub get
```

4. Start the flutter project:

- NOTE : The minimum API version required for running this project in android emulator is 33.

```bash
flutter run
```

5. Navigate to the backend directory:

```bash
cd ../farm_wise_backend
```

6. Install backend dependencies:

```bash
npm install
```

7. Configure environment variables:

    - Create a .env file in the farm_wise_backend directory.
    - Define environment variables : 

        - TOKEN_SECRET : A string for JWT verification
        - MONGOURL : Your mongoDB connection string
        - PORT : 3001


8. Start the development server:

```bash
npm start
```

The flutter project will run in the selected android emulator.
  
## Usage

1. Upon accessing the Mobile app, sign up as a new user, once as a buyer and once as a seller.
2. After authentication, sellers can view their sales stats in form of a dasboard, list their products for sale, and receive orders and fulfill them. 
3. In the same manner, buyers can see the products listed by sellers, and place orders, see the orders summary, history etc.

## Contributing

Contributions are always welcome!

if you find any issues or have suggestions for improvements, feel free to open an issue or create a pull request.


## Contact

For any inquiries or feedback, you can reach out to me at vdpshyamofficial@gmail.com or connect with me on [LinkedIn](https://www.linkedin.com/in/v-d-p-shyam-9b6ba3162/).
## Support Me

If you like my work, support me by [buying me a coffee](https://www.buymeacoffee.com/vdpshyam) : )

